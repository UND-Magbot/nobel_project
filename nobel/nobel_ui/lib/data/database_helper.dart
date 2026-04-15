import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/const.dart';
import 'nobel_data.dart';
import '../app_state.dart';

/// SQLite 데이터베이스 헬퍼
/// - measurements: 초/중/종 측정값
/// - measurement_meta: 날짜별 메타 정보 (작업자/관리자 등)
/// - plc_limits: PLC 기준값
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _dbDir = 'C:\\nobel\\data';
  static const String _dbName = 'nobel.db';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    Directory(_dbDir).createSync(recursive: true);
    final path = '$_dbDir\\$_dbName';

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createSchema,
      ),
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        check_num TEXT NOT NULL,
        stage INTEGER NOT NULL,
        value REAL NOT NULL,
        UNIQUE(name, date, check_num, stage)
      )
    ''');
    await db.execute('CREATE INDEX idx_measurements_name_date ON measurements(name, date)');

    await db.execute('''
      CREATE TABLE measurement_meta (
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        product_num TEXT,
        worker TEXT,
        admin TEXT,
        model TEXT,
        product TEXT,
        PRIMARY KEY(name, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE plc_limits (
        name TEXT NOT NULL,
        check_num TEXT NOT NULL,
        min_val REAL NOT NULL,
        max_val REAL NOT NULL,
        PRIMARY KEY(name, check_num)
      )
    ''');
  }

  // ============== Measurements ==============

  /// 모든 데이터를 메모리로 로드 (앱 시작 시 호출)
  Future<void> loadAllIntoMemory() async {
    final db = await database;

    final measurementRows = await db.query('measurements',
        orderBy: 'name, date, check_num, stage');
    final metaRows = await db.query('measurement_meta');

    // 메타 맵
    final Map<String, Map<String, Map<String, String>>> metaMap = {};
    for (final row in metaRows) {
      final name = row['name'] as String;
      final date = row['date'] as String;
      metaMap.putIfAbsent(name, () => {});
      metaMap[name]![date] = {
        'product_num': (row['product_num'] ?? '') as String,
        'worker': (row['worker'] ?? '') as String,
        'admin': (row['admin'] ?? '') as String,
        'model': (row['model'] ?? '') as String,
        'product': (row['product'] ?? '') as String,
      };
    }

    // name → date → checkNum → (stage → value) 로 그룹화
    final Map<String, Map<String, Map<String, Map<int, double>>>> byStage = {};
    for (final row in measurementRows) {
      final name = row['name'] as String;
      final date = row['date'] as String;
      final checkNum = row['check_num'] as String;
      final stage = row['stage'] as int;
      final value = (row['value'] as num).toDouble();

      byStage.putIfAbsent(name, () => {});
      byStage[name]!.putIfAbsent(date, () => {});
      byStage[name]![date]!.putIfAbsent(checkNum, () => {});
      byStage[name]![date]![checkNum]![stage] = value;
    }

    // Measurements.data를 빈 맵으로 초기화 (Constants.names 기준)
    Measurements.data = Map.from(Constants.JSON_DATA_MAP);

    // 각 (name, date)마다 Measurements 생성 후 값 채우기
    final Set<String> allDates = {};
    byStage.forEach((name, dateMap) {
      dateMap.forEach((date, checkMap) {
        // Measurements 생성자가 data[name][date]에 자동으로 this를 저장함
        final m = Measurements(
          date: date,
          name: name,
          measurements: {},
        );

        // 각 checkNum별로 stage 순서대로 List<double> 구성
        for (final checkNum in m.checkList) {
          final stageMap = checkMap[checkNum];
          final List<double> values = [];
          if (stageMap != null) {
            for (int s = 0; s < 3; s++) {
              if (stageMap.containsKey(s)) {
                values.add(stageMap[s]!);
              } else {
                break;
              }
            }
          }
          m.measurements[checkNum] = values;
        }

        // 메타 복원
        final meta = metaMap[name]?[date];
        if (meta != null) {
          m.productNum = meta['product_num'] ?? '';
          m.worker = meta['worker'] ?? '';
          m.admin = meta['admin'] ?? '';
          m.model = meta['model'] ?? '';
          m.product = meta['product'] ?? '';
        }

        allDates.add(date);
      });
    });

    // dateList 재구성 (정렬)
    final sortedDates = allDates.toList()..sort();
    Measurements.dateList = sortedDates;

    print('✅ DB 로드 완료: ${allDates.length}개 날짜, ${measurementRows.length}개 측정값');
  }

  /// 특정 소재/날짜의 측정값을 DB에 저장 (UPSERT)
  Future<void> saveMeasurements(Measurements m) async {
    final db = await database;
    final batch = db.batch();

    // 기존 데이터 삭제 후 재삽입 (간단한 업서트)
    batch.delete(
      'measurements',
      where: 'name = ? AND date = ?',
      whereArgs: [m.name, m.date],
    );

    for (String checkNum in m.measurements.keys) {
      final values = m.measurements[checkNum]!;
      for (int stage = 0; stage < values.length && stage < 3; stage++) {
        batch.insert('measurements', {
          'name': m.name,
          'date': m.date,
          'check_num': checkNum,
          'stage': stage,
          'value': values[stage],
        });
      }
    }

    // 메타 저장
    batch.insert(
      'measurement_meta',
      {
        'name': m.name,
        'date': m.date,
        'product_num': m.productNum,
        'worker': m.worker,
        'admin': m.admin,
        'model': m.model,
        'product': m.product,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await batch.commit(noResult: true);
  }

  /// 전체 메모리 데이터를 DB에 저장
  Future<void> saveAllFromMemory() async {
    Measurements.data.forEach((name, dateMap) {
      dateMap.forEach((date, m) {
        saveMeasurements(m);
      });
    });
  }

  /// 특정 소재/날짜의 데이터 전체 삭제
  Future<void> deleteMeasurement(String name, String date) async {
    final db = await database;
    await db.delete('measurements', where: 'name = ? AND date = ?', whereArgs: [name, date]);
    await db.delete('measurement_meta', where: 'name = ? AND date = ?', whereArgs: [name, date]);
  }

  // ============== PLC Limits ==============

  Future<void> savePlcLimits(Map<String, Map<String, Map<String, double>>> limits) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('plc_limits');
    limits.forEach((name, checkMap) {
      checkMap.forEach((checkNum, limitMap) {
        batch.insert('plc_limits', {
          'name': name,
          'check_num': checkNum,
          'min_val': limitMap['min'] ?? 0,
          'max_val': limitMap['max'] ?? 0,
        });
      });
    });

    await batch.commit(noResult: true);
  }

  Future<Map<String, Map<String, Map<String, double>>>> loadPlcLimits() async {
    final db = await database;
    final rows = await db.query('plc_limits');

    Map<String, Map<String, Map<String, double>>> result = {};
    for (var row in rows) {
      String name = row['name'] as String;
      String checkNum = row['check_num'] as String;
      result.putIfAbsent(name, () => {});
      result[name]![checkNum] = {
        'min': (row['min_val'] as num).toDouble(),
        'max': (row['max_val'] as num).toDouble(),
      };
    }
    return result;
  }

  // ============== 마이그레이션 ==============

  /// 기존 JSON 파일이 있으면 DB로 마이그레이션 (첫 실행 시 한 번)
  Future<void> migrateFromJsonIfNeeded() async {
    final db = await database;
    final existing = await db.query('measurements', limit: 1);
    if (existing.isNotEmpty) return; // 이미 데이터 있음

    // data.json 읽기
    final dataFile = File(Constants.dataPath);
    if (!await dataFile.exists()) return;

    try {
      final jsonString = await dataFile.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final batch = db.batch();
      jsonMap.forEach((name, dateMap) {
        (dateMap as Map<String, dynamic>).forEach((date, measurement) {
          final m = measurement as Map<String, dynamic>;
          final measurements = m['measurements'] as Map<String, dynamic>;

          measurements.forEach((checkNum, values) {
            final list = values as List;
            // 앞의 3개만 측정값 (뒤는 avg, xbar)
            for (int stage = 0; stage < list.length && stage < 3; stage++) {
              final v = list[stage];
              final dv = (v is num) ? v.toDouble() : 0.0;
              batch.insert('measurements', {
                'name': name,
                'date': date,
                'check_num': checkNum,
                'stage': stage,
                'value': dv,
              });
            }
          });

          batch.insert(
            'measurement_meta',
            {
              'name': name,
              'date': date,
              'product_num': m['product num'] ?? '',
              'worker': m['worker'] ?? '',
              'admin': m['admin'] ?? '',
              'model': m['model'] ?? '',
              'product': m['product'] ?? '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      });

      await batch.commit(noResult: true);
      print('✅ JSON → SQLite 마이그레이션 완료');
    } catch (e) {
      print('⚠️ 마이그레이션 실패: $e');
    }

    // PLC limits 마이그레이션
    final plcFile = File(Constants.plcLimitsPath);
    if (await plcFile.exists()) {
      try {
        final jsonString = await plcFile.readAsString();
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

        Map<String, Map<String, Map<String, double>>> limits = {};
        decoded.forEach((name, checkMap) {
          limits[name] = {};
          (checkMap as Map<String, dynamic>).forEach((checkNum, limitMap) {
            final lm = limitMap as Map<String, dynamic>;
            limits[name]![checkNum] = {
              'min': (lm['min'] as num).toDouble(),
              'max': (lm['max'] as num).toDouble(),
            };
          });
        });

        await savePlcLimits(limits);
        print('✅ PLC limits 마이그레이션 완료');
      } catch (e) {
        print('⚠️ PLC limits 마이그레이션 실패: $e');
      }
    }
  }
}
