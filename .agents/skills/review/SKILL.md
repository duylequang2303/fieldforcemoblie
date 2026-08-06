---
name: review
description: Kiểm tra mã nguồn, logic, và đảm bảo chất lượng trước khi commit hoặc triển khai.
---

# Review Skill

Skill này hướng dẫn agent cách kiểm tra mã nguồn, logic, và đảm bảo chất lượng trước khi commit hoặc triển khai. Review sẽ sử dụng API Google AI để phân tích và đánh giá mã nguồn.

## API Google AI
- **API Token**: `YOUR_GEMINI_API_KEY`
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent`
- **Header bắt buộc**:
  ```http
  Authorization: Bearer <GOOGLE_AI_REVIEW_TOKEN>
  Content-Type: application/json
  ```

## Cách sử dụng
1. **Kiểm tra mã nguồn**:
   - Sử dụng API Google AI để phân tích mã nguồn và phát hiện lỗi tiềm ẩn.
   - Gọi tool `fetch` để truy vấn API với diff mã nguồn hoặc đoạn code cần review.

2. **Đảm bảo chất lượng**:
   - Kiểm tra tính đúng đắn của logic, hiệu suất, và tuân thủ các best practice.
   - Tạo file marker `.cline/review-marker` sau khi review thành công để tránh bị git hook chặn.

## Ví dụ sử dụng
```bash
# Lệnh tạo file marker sau khi review thành công
mkdir -p .cline && date +%s > .cline/review-marker
```

```dart
// Ví dụ gọi API Google AI để review mã nguồn
final response = await fetch(
  url: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
  headers: {
    'Authorization': 'Bearer <GOOGLE_AI_REVIEW_TOKEN>',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'contents': [
      {
        'parts': [
          {
            'text': '''
            Phân tích đoạn mã sau và phát hiện lỗi tiềm ẩn:
            ```
            void updateUserProfile(User user) {
              if (user != null) {
                user.name = 'Updated Name';
              }
            }
            ```
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
- Luôn tạo file marker `.cline/review-marker` sau khi review thành công.