---
name: thinking
description: Phân tích, đánh giá, và đề xuất giải pháp cho các vấn đề phức tạp hoặc yêu cầu sáng tạo.
---

# Thinking Skill

Skill này hướng dẫn agent cách phân tích, đánh giá, và đề xuất giải pháp cho các vấn đề phức tạp hoặc yêu cầu sáng tạo. Thinking sẽ sử dụng API Google AI để hỗ trợ phân tích và đưa ra đề xuất.

## API Google AI
- **API Token**: `YOUR_GEMINI_API_KEY`
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent`
- **Header bắt buộc**:
  ```http
  Authorization: Bearer <GOOGLE_AI_THINKING_TOKEN>
  Content-Type: application/json
  ```

## Cách sử dụng
1. **Phân tích vấn đề**:
   - Sử dụng API Google AI để phân tích vấn đề và đề xuất giải pháp.
   - Gọi tool `fetch` để truy vấn API với mô tả vấn đề.

2. **Đề xuất giải pháp**:
   - Đánh giá các giải pháp tiềm năng và đề xuất giải pháp tối ưu.
   - Sử dụng `spawn_agent` để ủy thác công việc cho các sub-agent khác nếu cần.

## Ví dụ sử dụng
```dart
// Ví dụ gọi API Google AI để phân tích vấn đề
final response = await fetch(
  url: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
  headers: {
    'Authorization': 'Bearer <GOOGLE_AI_THINKING_TOKEN>',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'contents': [
      {
        'parts': [
          {
            'text': '''
            Đề xuất giải pháp cho vấn đề đồng bộ dữ liệu offline trong ứng dụng Flutter:
            - Dữ liệu cần đồng bộ: Danh sách khách hàng, đơn hàng, và sản phẩm.
            - Yêu cầu: Đảm bảo dữ liệu luôn nhất quán giữa offline và online.
            '''
          }
        ]
      }
    ]
  }),
);
```

## Lưu ý
- Không để lộ API Token trong các prompt hoặc log công khai.
- Sử dụng tool `spawn_agent` để ủy thác công việc cho các sub-agent khác nếu cần.