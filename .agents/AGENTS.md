# AGENTS.md – Quy tắc Code Dart/Flutter cho AI

## 1. Ngôn ngữ & Phong cách
- Tất cả **code** viết bằng **Dart**. Comment trong code viết **tiếng Anh**.
- Tất cả **tài liệu** (`.md`) và **comment giải thích nghiệp vụ** viết **tiếng Việt**.
- Dùng `prefer_single_quotes` cho tất cả string literal.

## 2. Cấu trúc Thư mục — Feature-First
- Mỗi tính năng nằm trong `lib/features/<feature_name>/` gồm: `models/`, `providers/`, `services/`, `pages/`, `widgets/`.
- Code dùng chung nhiều feature → đặt trong `lib/shared/`.
- Hạ tầng kỹ thuật (API, DB, Auth) → `lib/core/`.
- **Không bao giờ** import trực tiếp từ feature này vào feature khác. Giao tiếp qua `provider` hoặc `service` trong `core/`.

## 3. State Management — Provider
- Dùng `ChangeNotifier` + `Provider` / `Consumer`.
- Mỗi feature có 1 `XxxProvider extends ChangeNotifier`.
- `Provider` chỉ chứa state và logic điều phối. **Không** gọi Odoo API trực tiếp trong Provider — delegate sang `XxxService`.
- Không dùng `setState` trong các trang phức tạp (>2 state). Dùng `Consumer<XxxProvider>`.

## 4. Routing — go_router
- Toàn bộ route khai báo tập trung tại `lib/core/routing/app_router.dart`.
- Tên route dùng hằng số trong `lib/core/routing/route_names.dart`.
- Navigate bằng `context.go(RouteNames.xxx)` hoặc `context.push(RouteNames.xxx)`.
- **Không** dùng `Navigator.push()` trực tiếp.

## 5. Kết nối Odoo API
- Toàn bộ giao tiếp Odoo đi qua `OdooSessionManager` (singleton).
- Mỗi feature có `XxxService` riêng, chỉ gọi methods của `OdooSessionManager`.
- Wrap tất cả Odoo call bằng try/catch và throw `OdooApiException`.
- Không hardcode server URL / database name — đọc từ `flutter_secure_storage`.

## 6. Offline First
- Tất cả dữ liệu Odoo fetch về phải lưu vào **Isar DB** trước khi hiển thị.
- Khi offline: đọc từ Isar, hiển thị `OfflineBanner`.
- Khi online trở lại: `SyncManager` tự động push các thay đổi local lên Odoo.
- Model Isar đặt trong `features/<feature>/models/`, annotate `@collection`.

## 7. Naming Conventions
| Loại | Convention | Ví dụ |
|---|---|---|
| File | `snake_case.dart` | `orders_list_page.dart` |
| Class | `PascalCase` | `OrdersListPage` |
| Variable/Method | `camelCase` | `fetchOrders()` |
| Constant | `camelCase` | `routeOrders` |
| Isar Model | `PascalCase` + `@collection` | `FsmOrder` |

## 8. Error Handling
- Tất cả API call phải có error handling rõ ràng.
- Hiển thị lỗi qua `ErrorView` widget (trong `shared/widgets/`), không dùng `print()` hay `showSnackBar` inline.
- Dùng `logger.dart` (trong `core/utils/`) để log thay vì `print()`.

## 9. Những điều cấm
- ❌ Không dùng `dynamic` type — dùng kiểu cụ thể hoặc `Object?`.
- ❌ Không để code unreachable hoặc `TODO` lâu hơn 1 task.
- ❌ Không gọi Odoo API trực tiếp trong Widget hoặc Provider.
- ❌ Không import `dart:io` trong code business logic — chỉ trong service.

## 10. Odoo Backend Server
> ⚠️ **Bảo mật:** Toàn bộ thông tin nhạy cảm (URL, credentials, SSH key...) **KHÔNG được viết trực tiếp trong file này**. Chỉ đọc từ file `.env` (không đẩy lên git, đã có trong `.gitignore`). Nếu thiếu biến, yêu cầu User cung cấp hoặc kiểm tra `.env`.

- **Tất cả thông tin kết nối** đọc từ `.env`:
  - `ODOO_URL` → Server URL
  - `ODOO_ADMIN_USER` / `ODOO_ADMIN_PASSWORD` → Web Admin Credentials
  - `ODOO_SSH_TARGET` → SSH Target
  - `ODOO_SSH_PUBLIC_KEY` → SSH Public Key
  - `ODOO_CONFIG_FILE` → Odoo Config File
  - `ODOO_RESTART_CMD` → Restart Command
- Command mẫu (sau khi load `.env`):
  ```bash
  ssh "$ODOO_SSH_TARGET" "$ODOO_RESTART_CMD"
  ```

## 11. Quy tắc Cấu trúc dữ liệu Thợ & Thao tác Database
- ❌ **CẤM** tự ý chỉnh sửa, tạo mới hoặc ghi đè thông tin Kỹ thuật viên (`fsm.person`, `res_partner`, `res_users`) trên cơ sở dữ liệu Odoo trừ khi có yêu cầu bằng văn bản rõ ràng của User.
- 💡 **Sơ đồ ánh xạ tài khoản kiểm thử mặc định**:
  - **Tài khoản đăng nhập (App)**: `worker1@gmail.com` (User ID: `5`, Partner ID: `11` - tên "Kỹ thuật viên 1").
  - **Kỹ thuật viên phân công (Odoo)**: `James` (Person ID: `4`, Partner ID: `18`).
  - **Cơ chế lọc đơn hàng**: App di động của tài khoản `worker1@gmail.com` lọc đơn hàng thông qua người thực hiện dịch vụ là `James` (`person_id = 4`). Tất cả các đơn hàng kiểm thử cho thợ này bắt buộc phải gán `person_id = 4`.
- 📋 **Quy định tạo đơn hàng test chuẩn trên Odoo (phải đủ các trường bắt buộc để hiện lên Lịch trình)**:
  - `name`: Tên đơn hàng.
  - `person_id`: Gán cứng là `4` (James).
  - `location_id`: Gán mặc định là `18` (Vinhomes Landmark 81).
  - `stage_id`: Gán là `1` (New) hoặc `4` (In Progress).
  - `company_id`: Mặc định là `1`.
  - `team_id`: Mặc định là `1` (Bắt buộc NOT NULL).
  - `warehouse_id`: Mặc định là `1` (Bắt buộc NOT NULL).
  - `scheduled_date_start`: Thời gian bắt đầu (phải cùng ngày hiện tại để hiện lên lịch của app di động, ví dụ: `NOW()`).
  - `scheduled_date_end`: Thời gian kết thúc (ví dụ: `NOW() + INTERVAL '10 hours'`).
  - **Mẫu SQL insert chuẩn**:
    ```sql
    INSERT INTO fsm_order (
        name, person_id, location_id, stage_id, company_id, team_id, warehouse_id, 
        scheduled_date_start, scheduled_date_end, scheduled_duration, create_date, write_date, create_uid, write_uid
    ) VALUES (
        'Đơn FSM Test - ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'), 
        4, 18, 1, 1, 1, 1, 
        CURRENT_DATE + TIME '08:00:00', CURRENT_DATE + TIME '18:00:00', 10.0,
        NOW(), NOW(), 2, 2
    );
    ```
- ⚠️ **Hạn chế hỏi quyền tối đa**: Tránh chạy các lệnh shell thăm dò hoặc truy vấn rời rạc làm phiền User phê duyệt quyền nhiều lần. Nếu cần thông tin hoặc tạo dữ liệu test, hãy hỏi trực tiếp User hoặc gom các lệnh SQL/CLI cần thiết vào duy nhất một lần thực thi.

## 12. ~~Quy tắc sử dụng MCP Subagents (a2a-platform)~~ [DEPRECATED - Zed không hỗ trợ MCP]

> **Lưu ý:** Section này được giữ lại cho reference từ Cline setup cũ. Zed KHÔNG hỗ trợ MCP protocol native.
> Thay thế: Dùng Zed's `spawn_agent` tool (xem §13 THINK/SCOUT/REVIEW workflows).

<details>
<summary>Reference only (click to expand)</summary>

- 💡 **Tự động hóa Agent (a2a)**: Để tối ưu hóa chất lượng code và tránh rủi ro, AI nên chủ động gọi các subagents của `a2a-platform` tùy theo ngữ cảnh của nhiệm vụ:
  - **Khi Code/Refactor**: Sử dụng `softwareengineeringexpert` để hỗ trợ dọn rác, tái cấu trúc hoặc phát triển tính năng mới.
  - **Khi Review/Kiểm lỗi**: Sử dụng `constructivecritic` để kiểm tra chéo các thay đổi, đặc biệt là các logic nghiệp vụ quan trọng.
  - **Khi Sandbox/Thử nghiệm**: Sử dụng `sandboxcodingagent` để thử nghiệm mã nguồn một cách cô lập.
- ⚡ **Thiết lập Nhớ Bối cảnh**: Kết hợp các Rule này cùng với việc huấn luyện trí nhớ dài hạn (qua các công cụ lưu trữ như `supermemory` hoặc Agent Memory) để AI ở các phiên chat khác tự động nhận diện và phối hợp các bộ tool MCP một cách hiệu quả.

</details>

## 13. THINK Workflow & Subagent Delegation

### 🎯 THINK Workflow (Multi-agent Debate Pattern)

**Khi nào BẮT BUỘC dùng THINK:**
- Task phức tạp với >1 cách tiếp cận
- Rủi ro cao: đụng sync/Odoo/schema
- User báo bug nghiêm trọng cần verify
- Design decision quan trọng

**Pattern**: Spawn 3 subagents tranh luận:
- **PROPOSER** → đề xuất giải pháp đơn giản
- **SKEPTIC** → tấn công đề xuất, tìm lỗ hổng
- **CHECKER** → verify bằng code thực tế

→ Main agent tổng hợp → **FINAL PLAN** đã kiểm chứng

**📘 Chi tiết đầy đủ:** Xem [`.agents/THINK_WORKFLOW.md`](.agents/THINK_WORKFLOW.md)
- Templates cho 3 debaters
- Synthesis format
- Error handling
- Ví dụ thực tế từ project

### 🔧 Subagent Delegation (spawn_agent general guidelines)

**✅ Khi NÊN dùng spawn_agent:**

**1. Parallel Independent Tasks (song song không phụ thuộc)**
- ✅ Nhiều subtasks độc lập có thể chạy đồng thời
- ✅ Ví dụ: Research 3 libraries khác nhau cùng lúc, implement 3 features không overlap về file
```markdown
VD: Feature A cần research:
- Subagent 1: Tìm hiểu package X cho authentication
- Subagent 2: Tìm hiểu package Y cho state management
- Subagent 3: Đọc docs của API Z
→ Chạy song song, gộp kết quả sau
```

**2. Large Codebase Investigation (điều tra codebase lớn)**
- ✅ Cần tìm hiểu nhiều files/modules khác nhau
- ✅ Main agent focus vào implementation, delegate research cho subagent
```markdown
VD: Implement recurring feature:
- Main agent: Thiết kế data model
- Subagent: Đọc toàn bộ orders/ feature để hiểu pattern hiện tại
→ Main agent giữ context implementation, subagent research về báo cáo
```

**3. Review & Second Opinion (kiểm tra chéo)**
- ✅ Cần fresh perspective cho critical code
- ✅ Verify logic phức tạp, security-sensitive code
```markdown
VD: Sau khi implement authentication:
- Main agent: Đã viết xong auth_service.dart
- Subagent: Review security holes, suggest improvements
→ Subagent không có bias của implementation ban đầu
```

**4. Summarize Large Outputs (tóm tắt logs/outputs dài)**
- ✅ Build logs, test outputs quá dài (>500 lines)
- ✅ Main agent chỉ cần biết errors/warnings quan trọng
```markdown
VD: Chạy `flutter test` với 100+ test cases:
- Main agent: Run tests
- Subagent: Đọc full output, tóm tắt chỉ failures + root causes
→ Tiết kiệm context window của main agent
```

**5. Isolated Experiments (thử nghiệm cô lập)**
- ✅ Test approach mới mà không ảnh hưởng main context
- ✅ POC/prototype nhỏ trước khi integrate
```markdown
VD: Thử 2 approaches khác nhau:
- Subagent 1: Thử approach A (REST API)
- Subagent 2: Thử approach B (GraphQL)
→ So sánh kết quả, chọn approach tốt nhất
```

---

### ❌ KHI NÀO KHÔNG NÊN DÙNG spawn_agent

**1. Simple Tasks (task đơn giản, <3 tool calls)**
- ❌ Đọc 1 file, grep 1 pattern, sửa 1 function
- ✅ Làm trực tiếp nhanh hơn
```markdown
VD SAI: Delegate "đọc file config.dart và cho tôi biết API URL"
→ Tốn thời gian bootstrap subagent, main agent đọc trực tiếp chỉ 1 tool call
```

**2. Context-Dependent Tasks (phụ thuộc context hiện tại)**
- ❌ Task cần thông tin từ main agent conversation history
- ❌ Task cần kết quả vừa tìm được ở bước trước
```markdown
VD SAI (case thực tế từ CP1):
- Main agent vừa verify Odoo schema qua SSH (CP0)
- Delegate "verify fsm.frequency.set qua API" cho subagent
→ Subagent không có context CP0, phải research lại từ đầu
✅ ĐÚNG: Dùng schema đã biết từ CP0 + Odoo convention để thiết kế model trực tiếp
```

**3. Private/Sensitive Data Access (cần access file private)**
- ❌ Task cần đọc `.env`, credentials, SSH keys
- ❌ Subagent không có quyền, sẽ bị block
```markdown
VD SAI: "Authenticate Odoo và fetch data qua API"
→ Subagent không đọc được .env (private file), phải ask user nhiều lần
✅ ĐÚNG: Main agent có context .env, gọi API trực tiếp hoặc viết script test
```

**4. Sequential Dependencies (phụ thuộc tuần tự)**
- ❌ Step B cần kết quả của Step A
- ✅ Main agent làm tuần tự, dùng kết quả trước cho bước sau
```markdown
VD SAI:
- Subagent 1: Tìm file service
- Subagent 2: Đọc file service (chờ kết quả subagent 1)
→ Chậm gấp đôi, main agent làm tuần tự nhanh hơn
```

**5. Unclear Requirements (yêu cầu mơ hồ)**
- ❌ Task không rõ scope, cần clarify với user
- ❌ Subagent sẽ "nghĩ" lâu hoặc làm sai direction
```markdown
VD SAI: "Research best approach cho recurring feature"
→ Quá mơ hồ, subagent không biết constraints (Odoo backend, offline-first...)
✅ ĐÚNG: Main agent clarify với user trước, rồi delegate task cụ thể
```

---

### 📋 Checklist trước khi spawn_agent

Trả lời các câu hỏi sau trước khi delegate:

- [ ] **Task độc lập?** Subagent có đủ context để làm mà không cần hỏi main agent?
- [ ] **Task đủ lớn?** Task mất >5 tool calls hoặc >10 phút nếu main agent làm?
- [ ] **Không phụ thuộc private data?** Task không cần `.env`, credentials, session info?
- [ ] **Parallel được?** Task này có thể chạy song song với công việc main agent?
- [ ] **Giá trị rõ ràng?** Delegate tiết kiệm thời gian hoặc context window đáng kể?

**Nếu trả lời "Có" cho tất cả → ✅ NÊN DÙNG spawn_agent**

**Nếu có ≥2 câu trả lời "Không" → ❌ LÀM TRỰC TIẾP nhanh hơn**

---

### 💡 Best Practices khi dùng spawn_agent

**1. Message phải self-contained (đầy đủ context)**
```markdown
❌ SAI: "Tìm hiểu recurring feature trong project"
✅ ĐÚNG:
"Context: Project là Flutter app kết nối Odoo FSM backend. Feature hiện tại dùng Isar DB offline-first.
Task: Đọc toàn bộ lib/features/orders/ và lib/features/schedule/, tóm tắt:
1. Pattern gọi Odoo API (authentication, error handling)
2. Pattern lưu offline (Isar models, sync logic)
3. Các services hiện có và responsibilities
Output format: Markdown với code snippets minh họa."
```

**2. Scope rõ ràng, output cụ thể**
- Nói rõ subagent cần làm gì, không làm gì
- Định nghĩa output format (JSON, markdown, bullet points...)
- Giới hạn scope (files nào, models nào, không research thêm X/Y/Z)

**3. Follow-up với session_id**
- Reuse `session_id` khi cần follow-up trên cùng context
- Message follow-up ngắn gọn (subagent đã có context)
```dart
// Lần 1
spawn_agent(message: "Research X...") → session_id: "abc123"

// Follow-up
spawn_agent(
  session_id: "abc123",
  message: "Based on that, now compare approach A vs B"
)
```

**4. Gom parallel calls khi có thể**
```dart
// ✅ ĐÚNG: 3 subagents song song
spawn_agent(label: "Research auth", message: "...")
spawn_agent(label: "Research state", message: "...")
spawn_agent(label: "Research API", message: "...")
// Chờ cả 3 xong, gộp kết quả

// ❌ SAI: Sequential không cần thiết
spawn_agent → đợi xong → spawn_agent → đợi xong → spawn_agent
```

---

### 📊 Bài học từ thực tế (CP0-CP1)

**Case 1: Subagent chậm (CP1 - 2026-08-05)**
```markdown
Task: Verify fsm.frequency.set schema qua Odoo API
Vấn đề:
- Subagent cần authenticate Odoo (không có .env context)
- Cần research OdooService không tồn tại
- Main agent đã có schema từ CP0 (PostgreSQL)
→ Subagent "nghĩ" lâu, user cancel

Giải pháp:
- Main agent dùng schema PostgreSQL đã biết từ CP0
- Thiết kế model dựa trên Odoo convention (interval_type: daily/weekly/monthly)
→ Nhanh hơn, đủ để implement

Bài học: Task đơn giản + phụ thuộc context + cần private data → LÀM TRỰC TIẾP
```

**Case 2: Subagent verify bugs (CP0 - đã thành công ở session trước)**
```markdown
Task: Verify 5 bugs trong codebase (service_type, sync logic, recurring files...)
Kết quả:
- Subagent SKEPTIC + CHECKER chạy OK
- Phát hiện 2/5 bugs đã fix, 2 bugs files không tồn tại
→ Hữu ích cho verification

Nhưng:
- Main agent phải verify lại trực tiếp code để chắc chắn (đã chứng minh subagent sai ở bug #1)
→ Subagent report chỉ là hypothesis, cần verify bằng grep/read_file

Bài học: Subagent tốt cho research, nhưng main agent phải verify lại critical findings
```