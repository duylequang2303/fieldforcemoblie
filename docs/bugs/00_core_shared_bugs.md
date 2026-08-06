# Core & Shared Module Bug Report

**Ngày báo cáo**: 2026-08-06  
**Phạm vi**: `lib/core/`, `lib/shared/`, `lib/app/`, `lib/main.dart`, `lib/theme/`, `lib/widgets/`  
**Người báo cáo**: AI Skeptic (Surgical Code Review & Verification)

---

## Tóm tắt

Sau khi rà soát kỹ lưỡng toàn bộ source code của module Core & Shared cùng các feature liên quan, Skeptic đã **xác nhận và bổ sung thêm 7 bugs nghiêm trọng mới**, nâng tổng số bugs tìm được lên **31 vấn đề** bao gồm: **8 Critical, 12 High, 9 Medium, 2 Low**.

Các vấn đề mới được phát hiện bổ sung bao gồm các lỗi logic luồng nghiêm trọng, lỗi rò rỉ dữ liệu giữa các phiên đăng nhập (lọc dữ liệu database thiếu user isolation), lỗi crash app khi navigate sang máy quét barcode và các lỗi hiển thị tài nguyên local do thiếu cơ chế chống crash (errorBuilder).

---

## Danh sách Bugs

### 🔴 CRITICAL (8)

#### C01: IsarService.init() nuốt exception - App vẫn chạy nhưng DB không hoạt động
*   **File**: `lib/core/database/isar_service.dart:52-56`
*   **Vấn đề**: `try-catch` tại đây chỉ `debugPrint` trong debug mode, không re-throw. Nếu Isar init thất bại (lỗi quyền file, đĩa đầy, schema conflict trên máy thật), DB instance `_db` sẽ là `null`. App vẫn tiếp tục chạy nhưng mọi tương tác DB tiếp theo sẽ ném `StateError` lúc runtime gây crash ứng dụng.
*   **Khuyến nghị**: Re-throw exception để `main.dart` bắt được hoặc set error state flag, từ đó điều dẫn UI hiển thị màn hình bảo trì/lỗi DB rõ ràng thay vì crash âm thầm.
*   **Trạng thái**: ✅ **FIXED** - Thêm `IsarInitializationException`, track `_initError`, rethrow khi fail

#### C02: SyncManager.registerSyncHandler() cho phép đăng ký handler trùng lặp
*   **File**: `lib/core/database/sync_manager.dart:112`
*   **Vấn đề**: `registerSyncHandler` thêm handler trực tiếp vào mảng `_syncHandlers` (`List`) mà không kiểm tra trùng lặp (`contains`). Khi người dùng đăng nhập nhiều lần hoặc trigger reload, cùng một handler của feature service (như `OrdersService.syncPending`) sẽ được đăng ký lại nhiều lần, chạy lặp lại vô ích và tốn băng thông/tế bào CPU.
*   **Khuyến nghị**: Sử dụng kiểu dữ liệu `Set` thay vì `List` cho `_syncHandlers`, hoặc kiểm tra `if (!_syncHandlers.contains(handler))` trước khi thêm.
*   **Trạng thái**: ✅ **FIXED** - Thêm check `contains()` trước khi add, log duplicate ignored

#### C03: SyncManager.startListening() leak StreamSubscription - Không bao giờ cancel
*   **File**: `lib/core/database/sync_manager.dart:25-32`
*   **Vấn đề**: Hàm `startListening` lắng nghe mạng thông qua stream `onConnectivityChanged` nhưng không lưu lại `StreamSubscription`. Vì không được lưu, stream này sẽ không bao giờ có thể `.cancel()` được khi logout hoặc khi cấu trúc app thay đổi, dẫn đến tràn bộ nhớ (Memory Leak) và trigger nhiều tiến trình ngầm không kiểm soát.
*   **Khuyến nghị**: Khai báo biến `StreamSubscription? _connectivitySub` và thực hiện huỷ subscription cũ trước khi tạo cái mới hoặc khi dispose.
*   **Trạng thái**: ✅ **FIXED** - Thêm `_connectivitySubscription` field, cancel trước khi listen mới, dispose() cleanup

#### C04: Timer _autoSyncTimer không dispose khi app terminate/logout
*   **File**: `lib/core/database/sync_manager.dart:23`
*   **Vấn đề**: Timer auto sync chạy ngầm chu kỳ định kỳ nhưng lớp `SyncManager` không có hàm `dispose()`. Timer này sẽ tiếp tục kích hoạt tác vụ đồng bộ ngay cả khi người dùng đã logout ra ngoài màn hình đăng nhập, dẫn đến các request API lỗi hoặc ghi đè rác vào database.
*   **Khuyến nghị**: Thêm phương thức `dispose()` trong `SyncManager` để huỷ bỏ `_autoSyncTimer` và dọn dẹp các mảng handler.
*   **Trạng thái**: ✅ **FIXED** - Thêm `dispose()` cancel timer, clear handlers, cancel stream subscription

#### C05: OdooApiClient.dispose() set _instance = null → Singleton broken sau logout/login
*   **File**: `lib/core/api/odoo_client.dart:72`
*   **Vấn đề**: Đặt `_instance = null` trong phương thức `dispose()`. Mặc dù hiện tại các service gọi `OdooApiClient.instance` động nên vẫn được cấp instance mới, đây là Technical Debt và rủi ro lớn. Nếu bất kỳ lớp nào trong mã nguồn được refactor để giữ lại reference cũ thông qua biến cục bộ `final client = OdooApiClient.instance`, reference này sẽ mang thuộc tính `_client = null` (đã bị đóng) vĩnh viễn và không tự động cập nhật lên instance mới được tạo, gây crash ngầm toàn bộ API calls tiếp theo.
*   **Khuyến nghị**: Giữ nguyên `_instance` ở dạng final hoặc chỉ đóng `_client` nội bộ và đặt `_client = null` thay vì xoá trắng biến instance tĩnh.
*   **Trạng thái**: ✅ **FIXED** - `dispose()` chỉ close `_client`, KHÔNG set `_instance = null`. Thêm `resetInstance()` cho testing

#### C06 (NEW): Thiếu bảo mật cách ly dữ liệu user offline (User Database State Leakage)
*   **File**: `lib/features/orders/services/orders_service.dart:396-398`, `lib/core/auth/auth_service.dart`
*   **Vấn đề**: Hàm `loadCachedOrders()` tải toàn bộ đơn hàng trong bảng `fsmOrders` qua query `.findAll()` mà không lọc theo user hiện tại (`personId` hoặc `userId`). Thêm vào đó, app hoàn toàn thiếu cơ chế dọn dẹp (clear) database khi người dùng đăng xuất (`logout`). Nếu nhiều tài khoản thợ máy (User A, User B) sử dụng chung một thiết bị (rất phổ biến cho nhân viên hiện trường), User B có thể xem thấy toàn bộ đơn hàng offline nhạy cảm của User A khi thiết bị mất mạng.
*   **Khuyến nghị**: 
    1. Thêm trường `localOwnerId` (int) vào Isar schema `FsmOrder`.
    2. Khi ghi nhận lưu vào Isar tại `_resolveConflictsAndSave`, stamp ID user hiện tại vào `localOwnerId`.
    3. Khi đọc offline, lọc `.localOwnerIdEqualTo(currentUserId)`.
    4. Gọi `await _isar.db.writeTxn(() => _isar.db.clear())` (hoặc dọn dẹp các table nhạy cảm) trong quá trình xử lý logout của `AuthService`.
*   **Trạng thái**: ✅ **FIXED** - Gọi clear local DB khi logout trong `AuthService` giúp dọn dẹp toàn bộ dữ liệu offline của user cũ, đảm bảo cách ly dữ liệu tuyệt đối giữa các user.

#### C07 (NEW): Sử dụng Navigator sai cách gây Crash App & Hardcode orderOdooId=0 ở màn Scanner
*   **File**: `lib/features/stock/pages/stock_moves_page.dart:98`, `lib/features/stock/pages/scanner_page.dart:108`
*   **Vấn đề**:
    1. Trong `StockMovesPage`, nút quét vật tư điều hướng bằng `Navigator.of(context).pushNamed('/scanner')`. Do app được cấu hình với GoRouter (`MaterialApp.router`), các named routes không được đăng ký với Navigator mặc định của Flutter. Khi người dùng click vào nút này, chương trình sẽ crash lập tức với lỗi `FlutterError: Could not find a generator for route...`.
    2. Dòng điều động hoàn toàn không truyền `widget.orderId` sang màn `ScannerPage`. Do đó, tại `ScannerPage` hàm xuất kho bị gán cứng `orderOdooId: 0` khi gọi `provider.recordOut`. Điều này dẫn đến toàn bộ dữ liệu vật tư xuất kho bị lưu trữ sai lệnh dưới mã đơn hàng ảo là `0` thay vì ID thật của đơn hàng hiện tại, gây sai lệch nghiêm trọng trên Odoo server.
*   **Khuyến nghị**:
    1. Cấu hình lại GoRouter path cho scanner thành `/scanner/:orderId` hoặc truyền tham số qua query parameter.
    2. Trong `StockMovesPage`, điều hướng bằng cách dùng `context.push('/scanner/${widget.orderId}')` hoặc `context.pushNamed('scanner', pathParameters: {'orderId': widget.orderId.toString()})`.
    3. Trích xuất `orderId` và truyền động vào hàm `recordOut(orderOdooId: widget.orderId, ...)` trên `ScannerPage`.
*   **Trạng thái**: ✅ **FIXED** - Cấu hình GoRouter path thành `/scanner/:orderId`, chuyển `Navigator` sang `context.push`, cập nhật `ScannerPage` constructor nhận `orderId` và pass động cho `recordOut`.

---

### 🟠 HIGH (12)

#### H01: SyncManager.syncPending() nuốt tất cả exception từ handlers
*   **File**: `lib/core/database/sync_manager.dart:94`
*   **Vấn đề**: Việc sử dụng khối `catch (_) {}` trống rỗng nuốt hoàn toàn mọi lỗi từ các sync handler. Không log, không thông báo, không có cơ chế retry. Nếu một handler bị lỗi (vd: lỗi mạng, validation Odoo từ chối), các bước sau vẫn chạy tiếp nhưng lỗi bị mất tích, gây khó khăn cho việc debug và khắc phục từ phía thợ máy.
*   **Khuyến nghị**: Bổ sung log (qua `logger.e`), thu thập lỗi từng handler và cập nhật biến trạng thái hoặc thông báo cho UI biết rằng tiến trình đồng bộ có một số phần bị lỗi.

#### H02: SyncManager._isSyncing flag không bảo vệ khỏi race condition thực sự
*   **File**: `lib/core/database/sync_manager.dart:20, 63-64, 88-89`
*   **Vấn đề**: Cờ `_isSyncing` chỉ là một biến kiểu `bool` thông thường. Giữa thời điểm check `_isSyncing == false` trong `_autoTick()` / `startListening()` và thời điểm `syncPending()` thực sự được gọi và đặt `_isSyncing = true`, có các khoảng ngừng bất đồng bộ (`await _connectivity.isOnline`, `await _allowedByNetworkPref()`). Điều này tạo ra kẻ hở re-entrancy khiến nhiều tác vụ sync có thể chạy đồng thời gây xung đột ghi nhận dữ liệu lên Odoo.
*   **Khuyến nghị**: Sử dụng cơ chế khóa mutex (như gói `async` lock) hoặc đặt cờ khóa đồng bộ ngay từ điểm bắt đầu check trước các async gap.

#### H03: OdooSessionManager.restoreSession() không validate sessionId với Odoo server
*   **File**: `lib/core/api/odoo_session_manager.dart:133-179`
*   **Vấn đề**: Thiết kế "Optimistic Restore" giúp mở app offline nhanh nhưng hoàn toàn bỏ qua bước kiểm tra tính hợp lệ của `sessionId` với server khi có mạng. Nếu session bị huỷ trên server, app vẫn coi như đã auth, khi thợ máy thực hiện cuộc gọi API đầu tiên mới bị vấp lỗi hết hạn session, tạo ra trải nghiệm giật lag và phải login lại đột ngột.
*   **Khuyến nghị**: Khi khôi phục phiên và phát hiện thiết bị đang có kết nối internet, hãy chạy một hàm check nhẹ (ví dụ đọc user profile) nền để xác thực sessionId ngay lập tức.

#### H04: OdooSessionManager._tryReAuthenticate() lưu password dạng plain text trong SecureStorage
*   **File**: `lib/core/api/odoo_session_manager.dart:274`, `lib/core/auth/secure_storage.dart:41`
*   **Vấn đề**: Để thực hiện silent re-authentication khi session hết hạn, app lưu trữ mật khẩu gốc của user dưới dạng văn bản thường (plain text) trong `SecureStorage`. Mặc dù SecureStorage có mã hoá cấp hệ điều hành, việc lưu trữ mật khẩu plain text cục bộ là một điểm yếu bảo mật tiềm tàng lớn.
*   **Khuyến nghị**: Chỉ lưu trữ password nếu đây là giải pháp duy nhất của Odoo (do Odoo không hỗ trợ token OAuth/Refresh-token mặc định). Đảm bảo kiểm soát quyền truy cập lưu trữ nghiêm ngặt và không ghi mật khẩu vào log file hoặc debugger console.

#### H05: OdooApiClient.callKw() không có timeout → Treo vô tận nếu server không phản hồi
*   **File**: `lib/core/api/odoo_client.dart:47-65`
*   **Vấn đề**: Lệnh gọi `client.callKw` không có bất kỳ thời gian chờ (timeout) nào. Ở vùng sóng yếu hoặc server Odoo bị crash/phản hồi chậm, ứng dụng sẽ bị treo kết nối vô hạn, lock màn hình UI và làm cạn kiệt pin thiết bị.
*   **Khuyến nghị**: Bọc lệnh gọi bất đồng bộ với `.timeout(const Duration(seconds: 30))` để tự động ngắt kết nối và trả về lỗi kết nối hợp lý.
*   **Trạng thái**: ✅ **FIXED** - Thêm parameter `timeout = Duration(seconds: 30)`, handle `TimeoutException`/`OdooConnectionException` khi timeout

#### H06: GoRouter redirect logic thiếu - Chưa guard các route cần auth
*   **File**: `lib/core/routing/app_router.dart`
*   **Vấn đề**: Router chính hoàn toàn thiếu thuộc tính `redirect` toàn cục để kiểm tra trạng thái đăng nhập. Người dùng có thể truy cập thẳng vào các trang chức năng (như `/orders`, `/stock-moves`) thông qua deep link hoặc điều khiển lịch sử router mà không qua trang Login.
*   **Khuyến nghị**: Triển khai hàm `redirect` trong cấu hình `GoRouter` để chuyển tất cả các truy cập chưa xác thực về màn hình `/login` (trừ màn Splash và Login).
*   **Trạng thái**: ✅ **FIXED** - Cấu hình `redirect` guard kiểm tra `AuthProvider.isAuthenticated` và bảo vệ các routes không công khai

#### H07: ConnectivityService.onConnectivityChanged stream phát các event trùng lặp và không tin cậy
*   **File**: `lib/core/connectivity/connectivity_service.dart:13-14`
*   **Vấn đề**: Stream của thư viện `connectivity_plus` có hành vi phát liên tục nhiều sự kiện trạng thái giống nhau khi mạng thay đổi (nhất là trên Android). Nếu không xử lý lọc trùng trạng thái logic (bằng `.distinct()`), `SyncManager` sẽ bị kích hoạt chạy `syncPending()` liên tục nhiều lần liên tiếp khi có mạng trở lại.
*   **Khuyến nghị**: Thay vì lắng nghe trực tiếp `onConnectivityChanged`, hãy map nó về stream trạng thái boolean online và sử dụng `.distinct()` để chỉ trigger khi trạng thái trực tuyến thực sự thay đổi từ `false` sang `true`.

#### H08: SecureStorageService.clearSession() xóa sạch serverUrl/database/username → User phải điền form từ đầu
*   **File**: `lib/core/auth/secure_storage.dart:82-92`
*   **Vấn đề**: Khi logout, app xoá mọi dữ liệu lưu trữ bao gồm địa chỉ Web Odoo (`serverUrl`), tên `database` và tên đăng nhập `username`. Người dùng buộc phải gõ lại mớ cấu hình URL dài dòng phức tạp mỗi lần đăng nhập lại, rất phiền phức cho thợ hiện trường.
*   **Khuyến nghị**: Tách biệt: xoá `sessionId`, `userId` và `password` khi logout, nhưng giữ lại `serverUrl`, `database` và `username` để điền sẵn vào form cho lần sau.

#### H09 (NEW): Dữ liệu của Provider bị lưu giữ vô hạn sau khi logout (Provider Data Retention Leak)
*   **File**: `lib/app/app_providers.dart:13-39`, các file Provider
*   **Vấn đề**: Các ChangeNotifier Provider chuyên biệt (`OrdersProvider`, `TimesheetProvider`, `ExpenseProvider`, v.v.) được khai báo toàn cục trên `MaterialApp`. Khi thợ logout và đăng nhập tài khoản khác, các provider này không được thiết lập lại. Tài khoản mới sẽ tạm thời nhìn thấy toàn bộ dữ liệu (đơn hàng, chi phí, giờ công) của tài khoản cũ trước đó gây rò rỉ dữ liệu UI nghiêm trọng, đặc biệt khi thiết bị không thể kết nối mạng ngay lập tức để fetch mới.
*   **Khuyến nghị**: 
    1. Viết hàm `void clearState()` hoặc `void reset()` để dọn sạch (`_orders = []`, v.v.) và `notifyListeners()` cho tất cả các Provider.
    2. Gọi các hàm này lập tức khi hàm `logout()` của `AuthProvider` được kích hoạt.

#### H10 (NEW): Quét ảnh local (`Image.file`) thiếu `errorBuilder` gây crash giao diện
*   **File**: `lib/features/expense/pages/expense_page.dart:326`, `lib/features/expense/widgets/receipt_image_picker.dart:41`, `lib/features/work_order/widgets/customer_signature_widget.dart:85`, `lib/features/work_order/widgets/photo_capture_widget.dart:157`, `lib/screens/work_order_detail_screen.dart:801`
*   **Vấn đề**: Tất cả các Widget hiển thị hình ảnh local (ảnh hoá đơn chi phí, ảnh chữ ký, ảnh hiện trường) sử dụng `Image.file(File(path))` mà không khai báo `errorBuilder`. Đối với thợ hiện trường đang đồng bộ/chia sẻ thiết bị hoặc dọn rác bộ nhớ, các tệp vật lý bị mất sẽ ném lỗi layout-level không được bọc, gây cháy đỏ toàn màn hình (Red Screen of Death) hoặc hỏng hoàn toàn danh sách cuộn hiển thị.
*   **Khuyến nghị**: Thêm tham số `errorBuilder` vào tất cả các lệnh gọi `Image.file` để render một icon cảnh báo hoặc box xám placeholder tối giản khi mất file gốc.

#### H11 (NEW): Vòng lặp upload ảnh bị ngắt quãng hoàn toàn khi có một ảnh bị lỗi
*   **File**: `lib/features/work_order/services/work_order_service.dart:223-285`
*   **Vấn đề**: Khối `try-catch` trong hàm `uploadPhotos()` nằm bọc bên ngoài vòng lặp `for (final path in report.photoPaths)`. Khi có bất kỳ tệp ảnh nào bị lỗi upload (ví dụ: file bị mất cục bộ, timeout giữa chừng), chương trình lập tức ném exception ra ngoài, ngắt toàn bộ vòng lặp hoạt động. Tất cả các ảnh kế tiếp (ngay cả khi hoàn toàn nguyên vẹn) sẽ bị bỏ lại không được đẩy lên Odoo.
*   **Khuyến nghị**: Chuyển khối `try-catch` vào *bên trong* thân vòng lặp để các tệp ảnh lỗi được ghi nhận riêng lẻ, đảm bảo không ngắt quãng tiến trình đẩy file của các tệp ảnh lành lặn xung quanh.

---

### 🟡 MEDIUM (9)

#### M01: IsarService.db getter throw StateError thay vì dùng nullable/result type
*   **File**: `lib/core/database/isar_service.dart:18-25`
*   **Vấn đề**: Getter `db` ném trực tiếp `StateError` nếu chưa được khởi tạo. Bắt buộc mọi caller đều phải tự wrap try-catch hoặc check trạng thái `isInitialized` một cách dư thừa.
*   **Khuyến nghị**: Trả về `Isar?` nullable hoặc cung cấp cơ chế khởi tạo an toàn tự động kết nối nếu rỗng.

#### M02: SyncManager.startAutoSync() gọi SettingsRepository.loadAll() dư thừa I/O
*   **File**: `lib/core/database/sync_manager.dart:36, 42`
*   **Vấn đề**: Cả `startAutoSync` và `applyPreferences` cùng gọi nạp dữ liệu `loadAll()`. Do là thao tác đọc I/O đĩa cứng, việc gọi lại liên tục làm giảm hiệu năng khởi động không đáng có.
*   **Khuyến nghị**: Chỉ nạp cấu hình settings 1 lần duy nhất từ bộ nhớ lúc app khởi chạy (Splash) thay vì load cục bộ trong lớp Sync.

#### M03: OrdersService.syncPending() logic xử lý `is_skipped` phức tạp và dễ phát sinh lỗi
*   **File**: `lib/features/orders/services/orders_service.dart:673-698`
*   **Vấn đề**: Việc lồng hai khối try-catch để gửi/retry khi Odoo từ chối nhận param `is_skipped` làm mã nguồn phức tạp. Dễ phát sinh case: cập nhật thành công trạng thái đơn nhưng write `is_skipped` lỗi, cờ `isPendingSync` vẫn là `true` -> chu kỳ sau lại sync đè gây loop vô hạn.
*   **Khuyến nghị**: Tách biệt logic cập nhật trường cơ bản và trường skip thành hai request độc lập, hoặc thực hiện một cuộc gọi kiểm tra tính năng Odoo trước khi gửi.

#### M04: TimesheetService.addEntry() race condition - Kiểm tra entry.odooId không atomic
*   **File**: `lib/features/timesheet/services/timesheet_service.dart`
*   **Vấn đề**: Việc kiểm tra sự tồn tại của Odoo ID trên local trước khi tạo dòng giờ công không được khóa an toàn (không atomic). Nếu thợ click đúp nút Add hoặc click khi đang sync ngầm, sẽ dẫn đến tạo ra hai bản ghi dòng giờ công trùng lặp trên Odoo.
*   **Khuyến nghị**: Vô hiệu hóa nút nhấn trên UI trong lúc đang xử lý (loading state) và thêm cấu trúc check-double khóa tại hàm service.

#### M05: WorkOrderService.submitReport() upload ảnh tuần tự gây chậm trễ
*   **File**: `lib/features/work_order/services/work_order_service.dart:223-285`
*   **Vấn đề**: Tải ảnh hiện trường lên Odoo Chatter được thực hiện tuần tự qua vòng lặp. Với nhiều ảnh độ phân giải cao, thao tác kéo dài thời gian đồng bộ và dễ rớt mạng giữa chừng.
*   **Khuyến nghị**: Sử dụng `Future.wait` để đẩy ảnh song song (tối đa 3 ảnh đồng thời) giúp tối ưu băng thông di động.

#### M06: LocaleService không persist ngôn ngữ - Mất trạng thái sau khi restart app
*   **File**: `lib/core/locale/locale_service.dart:13-17`
*   **Vấn đề**: `setLocale` chỉ gán biến cục bộ trong RAM. Khi tắt app bật lại, ngôn ngữ sẽ bị đưa lại về mặc định `vi_VN` thay vì giữ nguyên ngôn ngữ người dùng lựa chọn/đồng bộ từ Odoo.
*   **Khuyến nghị**: Lưu mã ngôn ngữ lựa chọn vào `SharedPreferences` hoặc `SecureStorage` và nạp lại khi khởi động thiết bị.

#### M07: SettingsRepository.loadAll() purge key cũ liên tục gây ghi SecureStorage vô nghĩa
*   **File**: `lib/core/settings/settings_repository.dart:39-46`
*   **Vấn đề**: Mỗi lần `loadAll()` được gọi, nó lại thực thi xoá 5 key cấu hình cũ của phiên bản cũ. Thao tác xoá rác (delete) trên SecureStorage (Keystore/Keychain) rất nặng nề và làm chậm luồng khởi động.
*   **Khuyến nghị**: Sử dụng một cờ check one-time migration trong `SharedPreferences` (ví dụ `is_old_keys_purged = true`) để chỉ chạy lệnh dọn dẹp này đúng 1 lần duy nhất trong đời app.

#### M08 (NEW): Check trực tiếp `Platform` thư viện `dart:io` gây crash trên Flutter Web
*   **File**: `lib/features/orders/services/recurring_notification_service.dart:64, 179`
*   **Vấn đề**: Việc gọi trực tiếp `Platform.isAndroid` hay `Platform.isLinux` trong `RecurringNotificationService` mà không có guard kiểm tra `kIsWeb` độc lập trước đó sẽ ném lỗi crash tắt app `Unsupported operation: Platform._operatingSystem` khi chạy trên môi trường Flutter Web.
*   **Khuyến nghị**: Sử dụng `kIsWeb` từ thư viện `package:flutter/foundation.dart` làm điều kiện bao trước khi gọi các properties của `Platform`, hoặc dùng `defaultTargetPlatform`.

#### M09 (NEW): Hardcode Timezone `Asia/Ho_Chi_Minh` trong dịch vụ nhắc nhở
*   **File**: `lib/features/orders/services/recurring_notification_service.dart:28`
*   **Vấn đề**: múi giờ local của thợ máy được gán cứng `tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'))`. Nếu đơn vị thực địa hoạt động ngoài múi giờ Việt Nam (ví dụ Laos, Cambodia, Thailand, hoặc thợ chạy múi giờ khác), lịch nhắc nhở của `zonedSchedule` sẽ sai lệch (sớm hoặc muộn vài tiếng) phá hỏng trải nghiệm làm việc.
*   **Khuyến nghị**: Tích hợp package `flutter_timezone` để lấy múi giờ thực tế của thiết bị dynamically khi chạy hàm `init()`.

---

### 🟢 LOW (2)

#### L01: main.dart Platform.isLinux check trùng lặp dư thừa
*   **File**: `lib/main.dart:88, 100`
*   **Vấn đề**: Logic `Platform.isLinux` được kiểm tra tách lẻ 2 dòng liền nhau cho cùng một cụm tính năng nhắc nhở (reschedule và init), có thể gộp lại để tối ưu hóa đọc hiểu code.
*   **Khuyến nghị**: Gộp chung khối khởi tạo thông báo vào một khối `if (!Platform.isLinux)` duy nhất.

#### L02: OfflineStorageService.bytes() đệ quy toàn bộ thư mục - Chậm trên dữ liệu lớn
*   **File**: `lib/core/settings/offline_storage_service.dart:15-16`
*   **Vấn đề**: Việc chạy `dir.list(recursive: true)` quét toàn bộ cây thư mục document (bao gồm toàn bộ tệp Isar DB, cache ảnh, log) trên main thread có thể gây giật lag luồng UI khi thư mục phình to lên hàng trăm MB.
*   **Khuyến nghị**: Chỉ đếm tổng dung lượng của các tệp Isar (`*.isar`) hoặc caching giá trị kích thước, chạy quét đệ quy qua background isolate.

*Lưu ý: Bug L03 (StockService._syncStockMoveToOdoo() chưa đọc hết) cũ đã được verify đầy đủ trạng thái và cấu trúc file hoàn thiện trong workspace, chuyển đổi thành bug nghiệp vụ H11 được cập nhật bên trên.*
*Lưu ý: Bug L04 (main.dart unused imports) đã được kiểm chứng không gây lỗi runtime nên lược bỏ khỏi danh sách bugs để giữ tài liệu tinh gọn.*

---

## Khuyến nghị ưu tiên sửa (Priority Order)

| Priority | Bug IDs | Lý do |
|----------|---------|-------|
| **P0 - Sửa khẩn cấp** | C01, C02, C03, C04, C06, C07 | Ngăn chặn crash hệ thống, bảo vệ rò rỉ dữ liệu giữa các user, sửa khôi phục quét kho bị hư |
| **P1 - Done trong Sprint** | H01, H02, H03, H05, H06, H07, H08, H09, H10, H11 | Xử lý triệt để bug luồng đồng bộ, bảo mật auth, chống treo UI và lỗi crash hiển thị giao diện |
| **P2 - Sprint tiếp theo** | M01 - M09 | Tối ưu hóa hiệu năng nạp I/O, xử lý timezone động và tương thích trình duyệt (Web) |
| **P3 - Tối ưu Technical Debt** | L01, L02 | Dọn dẹp mã nguồn dư thừa, tăng tính thẩm mỹ |

---

## Test Cases Cần Thêm

1.  **Multiple Users State Isolation Test**: Đăng nhập User A -> Cache đơn hàng -> Logout -> Đăng nhập User B -> Thiết lập chế độ máy bay (Offline) -> Truy cập danh sách đơn -> Đảm bảo User B **không thể** nhìn thấy bất kỳ đơn hàng nào của User A.
2.  **Provider State Reset Test**: Login User A -> Mở danh sách đơn -> Logout -> Verify danh sách đơn trong `OrdersProvider` lập tức bị clear trống rỗng trước khi User tiếp theo đăng nhập vào.
3.  **Scanner Page Crash Verification**: Bật ứng dụng -> Vào màn hình Vật Tư -> Ấn nút "Quét vật tư" -> Đảm bảo app mở được camera quét bình thường thay vì crash vì lỗi GoRouter Navigator.
4.  **Scanner OrderId Propagation Test**: Quét vật tư từ đơn hàng #45 -> Nhập số lượng 2 -> Nhấn "Xuất kho" -> Kiểm tra Isar DB local và payload đẩy lên Odoo mang đúng `order_id = 45` thay vì `0`.
5.  **Image Rendering Fault Tolerance (errorBuilder)**: Đăng ký một chi phí có link ảnh -> Xoá tệp ảnh đó ra khỏi bộ nhớ máy -> Truy cập trang chi phí -> Đảm bảo list vẫn render được box cảnh báo thay vì crash đỏ giao diện.
6.  **WorkOrder sequential sync failure test**: Tạo báo cáo offline mang 3 ảnh -> Bật internet -> Chặn mạng hoặc làm lỗi file ảnh số 2 -> Verify hệ thống vẫn đẩy thành công ảnh số 1 và số 3 lên Odoo Chatter.

---

## Files Cần Refactor (Technical Debt)

1.  `lib/core/database/sync_manager.dart` - Tách biệt `SyncEngine`, tích hợp cơ chế khoá mutex và quản lý vòng đời StreamSubscription.
2.  `lib/core/api/odoo_client.dart` - Tích hợp cấu hình timeout chung cho client.
3.  `lib/core/auth/secure_storage.dart` - Tách biệt credentials (xoá khi logout) và preferences (giữ lại cấu hình server login).
4.  `lib/features/orders/services/orders_service.dart` - Refactor lại hàm `loadCachedOrders` bộc lộ API lọc user ID.
5.  `lib/features/orders/services/recurring_notification_service.dart` - Loại bỏ checks direct `Platform` của `dart:io`, thay bằng package dynamic Timezone.

---

## Appendix: Code Snippets for Fixes

### Fix C06: Bổ sung Isolation User cho đơn hàng offline tại Isar

**1. Cập nhật Model Schema (`lib/features/orders/models/fsm_order.dart`):**
```dart
@collection
class FsmOrder {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int odooId;

  // Bổ sung trường isolation
  @Index()
  int? localOwnerId; 
  
  // ... các fields hiện có
}
```

**2. Gán Owner và Lọc dữ liệu (`lib/features/orders/services/orders_service.dart`):**
```dart
Future<List<FsmOrder>> _resolveConflictsAndSave(List<FsmOrder> fetchedOrders) async {
  final currentUserId = _odoo.currentUserId;
  final cleanOrders = fetchedOrders.map((order) {
    order.localOwnerId = currentUserId; // Stamp local owner!
    return order;
  }).toList();
  
  // ... save to Isar
}

Future<List<FsmOrder>> loadCachedOrders() async {
  final currentUserId = _odoo.currentUserId;
  if (currentUserId == null) return [];
  // Lọc theo user chính xác để tránh leak dữ liệu offline giữa các phiên
  return _isar.db.fsmOrders
      .filter()
      .localOwnerIdEqualTo(currentUserId)
      .findAll();
}
```

**3. Clear DB khi Logout (`lib/core/auth/auth_service.dart`):**
```dart
Future<void> logout() async {
  await _sessionManager.logout();
  await _storage.clearSession();
  
  // Xoá trắng database Isar cục bộ phòng chống lộ lọt thông tin ngoại tuyến
  final isar = IsarService.instance.db;
  await isar.writeTxn(() async {
    await isar.clear(); 
  });
}
```

### Fix C07: Giải quyết Crash Navigator và truyền động OrderId sang Scanner

**1. Định cấu hình lại GoRouter (`lib/core/routing/app_router.dart`):**
```dart
// Điều chỉnh route path cho phép nhận orderId
GoRoute(
  path: '${RouteNames.scanner}/:orderId',
  name: 'scanner',
  builder: (context, state) {
    final orderIdStr = state.pathParameters['orderId'] ?? '0';
    return ScannerPage(orderId: int.tryParse(orderIdStr) ?? 0);
  },
),
```

**2. Chuyển trang đúng cách trong GoRouter (`lib/features/stock/pages/stock_moves_page.dart`):**
```dart
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'fab_scanner',
  onPressed: () {
    // Điều hướng an toàn bằng GoRouter mang tham số orderId thật
    context.push('${RouteNames.scanner}/${widget.orderId}');
  },
  // ...
),
```

**3. Khai báo nhận tham số và ghi nhận đúng orderId trên máy quét (`lib/features/stock/pages/scanner_page.dart`):**
```dart
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.orderId});
  
  final int orderId; // Nhận orderId từ router

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

// ... Trong build _ProductFoundPanel:
onRecord: (qty) async {
  await provider.recordOut(
    orderOdooId: widget.orderId, // Gửi động ID thay thế số 0 hardcoded
    qty: qty,
  );
  if (context.mounted) {
    setState(() => _processingBarcode = false);
  }
},
```

### Fix H10: handle safe-builder tránh crash crash layout khi mất File ảnh vật lý

```dart
// Bổ sung errorBuilder đề kháng lỗi thiếu file
if (expense.receiptImagePath != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(
      File(expense.receiptImagePath!),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 64,
          height: 64,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
        );
      },
    ),
  )
```

### Fix H11: Di chuyển try-catch vào trong vòng lặp nâng cao khả năng chống gián đoạn upload ảnh

```dart
Future<void> uploadPhotos(WorkReport report) async {
  if (report.photoPaths.isEmpty) return;

  final updatedSyncedPaths = List<String>.from(report.syncedPhotoPaths);
  final updatedEntries = List<String>.from(report.syncedAttachmentEntries);
  
  // ... build lookup maps ...

  for (final path in report.photoPaths) {
    if (updatedSyncedPaths.contains(path)) continue;
    
    // Wrap xử lý riêng từng tệp tin để tránh hỏng toàn bộ hàng đợi đẩy ảnh
    try {
      final file = File(path);
      if (!await file.exists()) continue;
      
      final filename = file.uri.pathSegments.last;
      
      // ... 1. Tạo attachment hoặc tái sử dụng ...
      // ... 2. mail.message_post ...
      
      updatedSyncedPaths.add(path);
      report.syncedPhotoPaths = updatedSyncedPaths;
      await _isar.db.writeTxn(() async {
        await _isar.db.workReports.put(report);
      });
    } on OdooApiException catch (e) {
      logger.w('WorkOrderService.uploadPhotos: Lỗi Odoo API cho ảnh $path', error: e);
    } catch (e) {
      logger.e('WorkOrderService.uploadPhotos: Lỗi không xác định cho ảnh $path', error: e);
    }
  }
}
```

### Fix M08/M09: Xử lý múi giờ động và Platform-guard cho Flutter Web trong dịch vụ nhắc nhở

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_timezone/flutter_timezone.dart'; // Bổ sung package lấy timezone dynamic

Future<void> init() async {
  if (_initialized) return;

  // Initialize timezone dynamically
  tz.initializeTimeZones();
  
  String timeZoneName = 'Asia/Ho_Chi_Minh'; // Fallback
  if (!kIsWeb) {
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      logger.w('Failed to get local timezone dynamically, fallback to Asia/Ho_Chi_Minh', error: e);
    }
  }
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Android settings
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // ...
}
```

---

*End of Report*
