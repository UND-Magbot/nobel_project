path = r"c:\Users\myckh\Desktop\nobel20251030\nobel20250828\nobel\nobel\nobel_ui\lib\pages\main_widget.dart"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find "작업자" text lines
worker_lines = []
for i, line in enumerate(lines):
    if "'작업자'," in line and i > 0 and 'Text(' in lines[i-1]:
        worker_lines.append(i)

print(f"Found {len(worker_lines)} worker sections")

# For each worker section, search backwards for "Padding(" with EdgeInsets.symmetric
insertions = []
tab_idx = 0
for wl in worker_lines:
    for j in range(wl, max(wl-15, 0), -1):
        stripped = lines[j].strip()
        if stripped == 'Padding(':
            insertions.append((j, tab_idx))
            print(f"  Tab {tab_idx}: insert before line {j+1}: '{lines[j].rstrip()}'")
            break
    tab_idx += 1

# Insert in reverse order
for insert_line, tab_idx in sorted(insertions, reverse=True):
    indent = ' ' * (len(lines[insert_line]) - len(lines[insert_line].lstrip()))
    widget_line = f"{indent}StageDeleteButton(nameIndex: {tab_idx}),\n"
    lines.insert(insert_line, widget_line)

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print(f"Inserted {len(insertions)} StageDeleteButtons")
