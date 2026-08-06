---
name: scout
description: Thu thập thông tin, tìm kiếm tài nguyên, và khám phá giải pháp cho các yêu cầu kỹ thuật hoặc nghiên cứu.
---

# Scout Skill

Skill này hướng dẫn agent cách thu thập thông tin, tìm kiếm tài nguyên, và khám phá giải pháp cho các yêu cầu kỹ thuật hoặc nghiên cứu. Scout sẽ sử dụng API Google AI để hỗ trợ tìm kiếm và phân tích thông tin.

## API Google AI
- **API Token**: `YOUR_GEMINI_API_KEY`
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent`
- **Header bắt buộc**:
  ```http
  Authorization: Bearer <GOOGLE_AI_SCOUT_TOKEN>
  Content-Type: application/json
  ```

## Cách sử dụng
1. **Thu thập thông tin**:
   - Sử dụng API Google AI để tìm kiếm tài liệu, ví dụ, hoặc giải pháp cho các vấn đề kỹ thuật.
   - Gọi tool `fetch` để truy vấn API với prompt phù hợp.

2. **Khám phá giải pháp**:
   - Đề xuất các giải pháp tiềm năng dựa trên thông tin thu thập được.
   - Sử dụng `spawn_agent` để ủy thác công việc cho các sub-agent khác nếu cần.

## Ví dụ sử dụng
```dart
// Ví dụ gọi API Google AI để tìm kiếm giải pháp
final response = await fetch(
  url: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
  headers: {
    'Authorization': 'Bearer <GOOGLE_AI_SCOUT_TOKEN>',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': 'Tìm giải pháp tối ưu cho đồng bộ dữ liệu offline trong Flutter sử dụng Isar DB.'}
        ]
      }
    ]
  }),
);
```

## Lưu ý
- Không để lộ API Token trong các prompt hoặc log công khai.
- Sử dụng tool `spawn_agent` để ủy thác công việc cho các sub-agent khác nếu cần.