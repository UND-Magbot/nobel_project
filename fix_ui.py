import os

path = r"c:\Users\myckh\Desktop\nobel20251030\nobel20250828\nobel\nobel\nobel_ui\lib\pages\main_widget.dart"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. 안내문 박스 여백 개선
content = content.replace(
    "16.0 *\n                                                                    scaleFactor,\n                                                                4.0 *\n                                                                    scaleFactor,\n                                                                16.0 *\n                                                                    scaleFactor,\n                                                                0.0 *\n                                                                    scaleFactor),\n                                                    child: Text(",
    "20.0 *\n                                                                    scaleFactor,\n                                                                16.0 *\n                                                                    scaleFactor,\n                                                                20.0 *\n                                                                    scaleFactor,\n                                                                12.0 *\n                                                                    scaleFactor),\n                                                    child: Text("
)

# 2. 차종(모델) 라벨: 배경색 -> 네이비, 라운드 왼쪽, 높이 조정
old_model_label = """                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F5F9),
                                                        border: Border.all(
                                                        color: const Color(0xFFD1D5DB),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                                        child: Text(
                                                        '\xec\xb0\xa8\xec\xa2\x85(\xeb\xaa\xa8\xeb\x8d\xb8)',"""

new_model_label = """                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.055,
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xFF1E3A5F),
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(10),
                                                          bottomLeft: Radius.circular(10),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                                        child: Text(
                                                        '\xec\xb0\xa8\xec\xa2\x85(\xeb\xaa\xa8\xeb\x8d\xb8)',"""

# Encode to match
old_model_label_u = old_model_label.encode('utf-8').decode('utf-8')
new_model_label_u = new_model_label.encode('utf-8').decode('utf-8')

content = content.replace(old_model_label_u, new_model_label_u)

# 차종 텍스트 색상 black -> white
content = content.replace(
    "color: Colors.black,\n                                                                fontSize: scaleFactor * 25.0,\n                                                                letterSpacing: 0.0,\n                                                                fontWeight: FontWeight.w600,\n                                                            ),\n                                                        ),\n                                                    ),\n                                                    ),\n\n                                                    // \xec\x9e\x85\xeb\xa0\xa5\xec\xb0\xbd \xec\xbb\xa8\xed\x85\x8c\xec\x9d\xb4\xeb\x84\x88\n                                                    Container(\n                                                    width: MediaQuery.sizeOf(context).width * 0.18,\n                                                    height: MediaQuery.sizeOf(context).height * 0.06,",
    "color: Colors.white,\n                                                                fontSize: scaleFactor * 22.0,\n                                                                letterSpacing: 0.0,\n                                                                fontWeight: FontWeight.w600,\n                                                            ),\n                                                        ),\n                                                    ),\n                                                    ),\n\n                                                    // \xec\x9e\x85\xeb\xa0\xa5\xec\xb0\xbd \xec\xbb\xa8\xed\x85\x8c\xec\x9d\xb4\xeb\x84\x88\n                                                    Container(\n                                                    width: MediaQuery.sizeOf(context).width * 0.18,\n                                                    height: MediaQuery.sizeOf(context).height * 0.055,"
)

# 차종 입력칸 라운드 오른쪽
content = content.replace(
    "height: MediaQuery.sizeOf(context).height * 0.055,\n                                                    decoration: BoxDecoration(\n                                                        color: FlutterFlowTheme.of(context).secondaryBackground,\n                                                        border: Border.all(\n                                                        color: const Color(0xFFD1D5DB),\n                                                        ),\n                                                    ),\n                                                    child: Align(\n                                                        alignment: const AlignmentDirectional(0.0, 0.0),",
    "height: MediaQuery.sizeOf(context).height * 0.055,\n                                                    decoration: BoxDecoration(\n                                                        color: FlutterFlowTheme.of(context).secondaryBackground,\n                                                        border: Border.all(color: const Color(0xFFD1D5DB)),\n                                                        borderRadius: const BorderRadius.only(\n                                                          topRight: Radius.circular(10),\n                                                          bottomRight: Radius.circular(10),\n                                                        ),\n                                                    ),\n                                                    child: Align(\n                                                        alignment: const AlignmentDirectional(0.0, 0.0),"
)

# 3. 품번 라벨: 네이비 배경 + 라운드 왼쪽
content = content.replace(
    """Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F5F9),
                                                        border: Border.all(
                                                        color: const Color(0xFFD1D5DB),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                        '\xed\x92\x88\xeb\xb2\x88',
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                fontFamily: 'Inter',
                                                                color: Colors.black,""",
    """Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.055,
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xFF1E3A5F),
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(10),
                                                          bottomLeft: Radius.circular(10),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                        '\xed\x92\x88\xeb\xb2\x88',
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                fontFamily: 'Inter',
                                                                color: Colors.white,"""
)

# 품번 입력칸: 높이 + 라운드 오른쪽
content = content.replace(
    """width: MediaQuery.sizeOf(context).width * 0.18,
                                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                                    decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        border: Border.all(
                                                        color: const Color(0xFFD1D5DB),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,""",
    """width: MediaQuery.sizeOf(context).width * 0.18,
                                                    height: MediaQuery.sizeOf(context).height * 0.055,
                                                    decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        border: Border.all(color: const Color(0xFFD1D5DB)),
                                                        borderRadius: const BorderRadius.only(
                                                          topRight: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,"""
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')
