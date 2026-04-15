// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import '../data/nobel_data.dart';

class Constants {
  // Prevent instantiation
  Constants._();

  static const String dataPath = "C:\\nobel\\data\\data.json";
  static const String dateListPath = "C:\\nobel\\data\\dateList.json";
  static const String excelPath = "C:\\nobel\\form.xlsx";
  static const String plcLimitsPath = 'C:\\nobel\\data\\plc_limits.json';

  static const List names = [
    'MS-010',
    'MS-011',
    'MS-012',
    'MS-013',
    'MS-014',
    'MS-015'
  ];

  static const Map sheetNames = {
    'MS-010': 'Aurora1 8 SUS304 Male tube 성형',
    'MS-011': 'Aurora1 12 SUS304  Male tube 성형',
    'MS-012': 'Aurora1 8 SUS304 이중축관성형',
    'MS-013': 'Aurora1 12 SUS304 이중축관성형',
    'MS-014': 'Aurora1 4.76사두 성형',
    'MS-015': 'Aurora1 4.76나팔 120° FLARE성형'
  };

  static const List<String> indexNames = ['초', '중', '종'];
  static const VALUE_LENGTH = 3;

  // General DATA Constants

  static List getDataParams(String name) {
    switch (name) {
      // 소재 이름, [기준값...], [오차값-규격한계, 오차값-관리한계...], [검사항목 번호...]
      case 'MS-010':
        return MS010;
      case 'MS-011':
        return MS011;
      case 'MS-012':
        return MS012;
      case 'MS-013':
        return MS013;
      case 'MS-014':
        return MS014;
      case 'MS-015':
        return MS015;
    }
    return [];
  }

  static const cellIndex = {
    'date': ['L7', 'T7', 'AB7'],
    'values': [
      'L10',
      'T10',
      'AB10',
    ]
  };

  static const MS010 = [
    'MS-010',
    [7.89, 10.98, 4.95, 1.7, 21.12], //검사기준
    ["1", "2", "3", "4", "5"], //검사 표 번호
    [0.06, -0.06, 0.15, -0.15, 0.25, -0.25, 0.1, -0.1, 0.25, -0.25], //오차값
    {
      // "2": [7.89, -0.06, 0.06],
      // "4": [4.95, -0.25, 0.25],
      // "5": [1.7, -0.1, 0.1],
      // "6": [21.12, -0.25, 0.25]
    },
    13
  ];
  static const MS011 = [
    'MS-011',
    [11.8, 16.51, 7.75, 2.54, 26.62],
    ["1", "2", "3", "4", "5"],
    [0.1, -0.1, 0.25, -0.25, 0.25, -0.25, 0.2, -0.2, 0.5, -0.5],
    {
      // "2": [11.8, -0.1, 0.1],
      // "4": [7.75, -0.25, 0.25],
      // "5": [2.54, -0.2, 0.2],
      // "6": [26.62, -0.5, 0.5]
    },
    13
  ];
  static const MS012 = [
    'MS-012',
    [6.75, 8.8, 9.0, 1.4],
    ["1", "2", "3", "4"],
    [0.1, -0.1, 0.2, -0.2, 0.2, -0.2, 0.1, -0.1],
    {
      // "2": [6.75, -0.1, 0.1],
      // "5": [1.4, -0.1, 0.1]
    },
    13
  ];
  static const MS013 = [
    'MS-013',
    [11.45, 13.5, 13.5, 1.4],
    ["1", "2", "3", "4"],
    [0.1, -0.1, 0.2, -0.2, 0.2, -0.2, 0.1, -0.1],
    {
      // "2": [11.45, -0.1, 0.1],
      // "4": [13.5, -0.2, 0.2],
      // "5": [1.4, -0.1, 0.1]
    },
    13
  ];
  static const MS014 = [
    'MS-014',
    [7.1, 3.2, 115.0, 3.0, 5.11, 0.2],
    ["1", "2", "3", "4", "5", "6"],
    [0.4, -0.18, 0.2, -0.1, 2.0, -2.0, 1.0, 0, 0.08, -0.08, 0, -0.2],
    [
      0.38,
      -0.16,
      0.18,
      -0.08,
      1.97,
      -1.97,
      0.03,
      -0.03,
      0.07,
      -0.07,
      -0.01,
      -0.19
    ],
    {
      // "5": [3.5, -0.5, 0.5, -0.47, 0.47],
      // "6": [5.11, -0.08, 0.08, -0.07, 0.07],
      // "7": [0, -0.2, 0.2, -0.19, 0.19]
    },
    14
  ];
  static const MS015 = [
    'MS-015',
    [7.1, 3.2, 1.4, 120.0, 3.0, 5.11, 0.2],
    ["1", "2", "3", "4", "5", "6", "7"],
    [
      0.4,
      -0.2,
      0.2,
      -0.1,
      0.2,
      -0.2,
      2.0,
      -2.0,
      1.0,
      0.0,
      0.08,
      -0.08,
      0,
      -0.2
    ],
    [
      0.38,
      -0.18,
      0.18,
      -0.08,
      0.19,
      -0.19,
      1.97,
      -1.97,
      0.03,
      -0.03,
      0.07,
      -0.07,
      -0.01,
      -0.19
    ],
    {
      // "4": [1.4, -0.2, 0.2, -0.19, 0.19],
      // "6": [3.5, -0.5, 0.5, -0.47, 0.47],
      // "7": [5.11, -0.08, 0.08, -0.07, 0.07],
      // "8": [0, -0.2, 0.2, -0.19, 0.19]
    },
    15
  ];

  static Map<String, Map<String, Measurements>> JSON_DATA_MAP =
      Map.unmodifiable({
    "MS-010": <String, Measurements>{},
    "MS-011": <String, Measurements>{},
    "MS-012": <String, Measurements>{},
    "MS-013": <String, Measurements>{},
    "MS-014": <String, Measurements>{},
    "MS-015": <String, Measurements>{}
  });
}
