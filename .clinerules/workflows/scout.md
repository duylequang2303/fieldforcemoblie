# /scout Workflow

## Invocation: `/scout <target_area>`

## Mục đích
Research nhanh một vùng code (hoặc tìm thông tin web) TRƯỚC khi main agent bắt tay vào làm. Subagent KHÔNG được sửa file.

## Prompt template cho subagent
```
Bạn là subagent SCOUT. Nhiệm vụ: nghiên cứu <target_area> trong repo fieldforcemoblie
và trả về briefing ≤500 từ. TUYỆT ĐỐI KHÔNG sửa, tạo, hay xóa bất kỳ file nào.

Trả về đúng định dạng:
KEY FILES | <đường dẫn file quan trọng nhất, cách nhau bởi dấu phẩy>
DATA FLOW | <mô tả ngắn luồng dữ liệu/chương trình giữa các file>
REFS | <file:line cụ thể cho các điểm then chốt, mỗi ref trên 1 dòng>
OPEN QUESTIONS | <điểm chưa rõ cần main agent đọc thêm>

Dùng các tool: search_files, list_code_definition_names, read_file để điều tra.
Nếu cần thông tin ngoài (thư viện, API, best practice) dùng agent-search/free_search.
Chỉ trả briefing, không kèm code thừa.
```

## Ghi chú cho main agent
- Luôn chỉ định rõ `<target_area>` (vd: "lib/features/orders + Odoo sync")
- Nhận briefing → quyết định file nào đọc tiếp; KHÔNG đọc lại toàn bộ các file subagent đã cover
- Nếu subagent trả output >500 từ hoặc thiếu REFS → coi là lỗi, đọc trực tiếp các file then chốt