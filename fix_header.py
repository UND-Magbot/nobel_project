path = r"c:\Users\myckh\Desktop\nobel20251030\nobel20250828\nobel\nobel\nobel_ui\lib\pages\main_widget.dart"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
i = 0
changes = 0

while i < len(lines):
    line = lines[i]

    # 빈 Row 제거 (children이 비어있는 Row)
    if 'children: [' in line and i+2 < len(lines):
        next_stripped = lines[i+1].strip()
        next2_stripped = lines[i+2].strip() if i+2 < len(lines) else ''
        if next_stripped == '' and next2_stripped == '],':
            # 빈 children - Row 시작부분 찾기
            # 위로 올라가서 Row( 찾기
            j = len(new_lines) - 1
            while j >= 0 and 'Row(' not in new_lines[j]:
                j -= 1
            if j >= 0 and 'Row(' in new_lines[j]:
                # Row 시작부터 현재까지 삭제
                new_lines = new_lines[:j]
                # children 닫는 ], 건너뛰기
                i += 3  # skip ], and Row closing ),
                # Find the closing ),
                while i < len(lines) and lines[i].strip() in ['', '],', '),']:
                    i += 1
                changes += 1
                continue

    # Row1 높이 통일: 0.06 -> 0.05 (상단 헤더 영역 - height 0.152 컨테이너 내부)
    # Row3 높이 통일: 0.04 -> 0.05

    new_lines.append(line)
    i += 1

content = ''.join(new_lines)

# 높이 통일 - 상단 헤더의 공정명 Row (height 0.06 셀들 -> 0.05)
# 구분 Row (height 0.04 셀들 -> 0.05)
# 공정명 셀 폭 0.09 -> 0.07

# Row1: 공정명 폭 수정
content = content.replace(
    "0.09,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.06,",
    "0.07,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.05,"
)

# Row1: 값 셀 높이 0.06 -> 0.05 (0.16 폭 셀)
content = content.replace(
    "0.16,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.06,",
    "0.18,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.05,"
)

# Row1: 특별특성 셀 높이 0.06 -> 0.05 (0.07 폭 + 특별특성)
content = content.replace(
    "0.07,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.06,",
    "0.07,\n                                                        height:\n                                                            MediaQuery.sizeOf(\n                                                                        context)\n                                                                    .height *\n                                                                0.05,"
)

# Row3: 모든 0.04 높이 셀 -> 0.05
content = content.replace(
    "0.04,\n                                                        decoration:",
    "0.05,\n                                                        decoration:"
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f'Empty rows removed: {changes}')
print('Heights aligned')
