path = r"c:\Users\myckh\Desktop\nobel20251030\nobel20250828\nobel\nobel\nobel_ui\lib\pages\main_widget.dart"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. 차종 입력칸: borderRadius 없는 것 -> 추가, 높이 통일 0.05
# 차종 입력칸 패턴 (border만 있고 borderRadius 없는 것)
content = content.replace(
    """                                                    // 입력창 컨테이너
                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.18,
                                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                                    decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        border: Border.all(
                                                        color: const Color(0xFFD1D5DB),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                                        child: TextFormField(""",
    """                                                    // 입력창 컨테이너
                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.18,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        border: Border.all(color: const Color(0xFFD1D5DB)),
                                                        borderRadius: const BorderRadius.only(
                                                          topRight: Radius.circular(10),
                                                          bottomRight: Radius.circular(10),
                                                        ),
                                                    ),
                                                    child: Align(
                                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                                        child: TextFormField("""
)

# 2. 품번 입력칸: 높이 0.055 -> 0.05 통일
content = content.replace(
    """                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.18,
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
                                                        alignment: Alignment.center,""",
    """                                                    Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.18,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
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

# 3. 라벨 높이 0.06 -> 0.05 통일 (차종/품번)
content = content.replace(
    """                                                    height: MediaQuery.sizeOf(context).height * 0.06,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFF1E3A5F),
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),""",
    """                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFF1E3A5F),
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),"""
)

# 4. 차종과 품번 사이에 간격 추가
# 품번 라벨 Container 앞에 SizedBox 추가
content = content.replace(
    """                                                Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFF1E3A5F),
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                        '\ud488\ubc88',""",
    """                                                const SizedBox(width: 20),
                                                Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.07,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFF1E3A5F),
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                    ),
                                                    child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                        '\ud488\ubc88',"""
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')
