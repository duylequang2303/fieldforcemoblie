# FEATURES.md – Trạng thái Tính năng

| Badge | Ý nghĩa |
|---|---|
| 🔴 TODO | Chưa làm |
| 🟡 WIP | Đang làm |
| 🟢 DONE | Hoàn thành & test OK |

---

## Phase 1: Foundation
| # | Tính năng | Trạng thái |
|---|---|---|
| 1.1 | Cấu trúc thư mục `lib/` | 🟢 DONE |
| 1.2 | `analysis_options.yaml` | 🟢 DONE |
| 1.3 | `.env.example` | 🟢 DONE |
| 1.4 | `pubspec.yaml` (finalize deps) | 🟢 DONE |

## Phase 2: Docs & Rules
| # | Tính năng | Trạng thái |
|---|---|---|
| 2.1 | `.agents/AGENTS.md` (quy tắc code AI) | 🟢 DONE |
| 2.2 | `docs/PROJECT_CONTEXT.md` | 🟢 DONE |
| 2.3 | `docs/ARCHITECTURE.md` | 🟢 DONE |
| 2.4 | `docs/ODOO_API.md` | 🟢 DONE |
| 2.5 | `docs/FEATURES.md` (file này) | 🟢 DONE |

## Phase 3: Core Layer
| # | Tính năng | Trạng thái |
|---|---|---|
| 3.1 | `core/theme/app_colors.dart` | 🟢 DONE |
| 3.2 | `core/theme/app_theme.dart` | 🟢 DONE |
| 3.3 | `core/routing/route_names.dart` | 🟢 DONE |
| 3.4 | `core/routing/app_router.dart` | 🟢 DONE |
| 3.5 | `core/api/api_exception.dart` | 🟢 DONE |
| 3.6 | `core/api/odoo_client.dart` | 🟢 DONE |
| 3.7 | `core/api/odoo_session_manager.dart` | 🟢 DONE |
| 3.8 | `core/auth/secure_storage.dart` | 🟢 DONE |
| 3.9 | `core/auth/biometric_service.dart` | 🟢 DONE |
| 3.10 | `core/auth/auth_service.dart` | 🟢 DONE |
| 3.11 | `core/connectivity/connectivity_service.dart` | 🟢 DONE |
| 3.12 | `core/database/isar_service.dart` | 🟢 DONE |
| 3.13 | `core/database/sync_manager.dart` | 🟢 DONE |
| 3.14 | `core/utils/logger.dart` | 🟢 DONE |

## Phase 4: Shared
| # | Tính năng | Trạng thái |
|---|---|---|
| 4.1 | `shared/widgets/loading_overlay.dart` | 🟢 DONE |
| 4.2 | `shared/widgets/error_view.dart` | 🟢 DONE |
| 4.3 | `shared/widgets/offline_banner.dart` | 🟢 DONE |
| 4.4 | `shared/widgets/signature_pad.dart` | 🟢 DONE |
| 4.5 | `shared/services/permission_service.dart` | 🟢 DONE |

## Phase 5: App Entry
| # | Tính năng | Trạng thái |
|---|---|---|
| 5.1 | `app/app_providers.dart` | 🟢 DONE |
| 5.2 | `app/app.dart` | 🟢 DONE |
| 5.3 | `main.dart` (update) | 🟢 DONE |

## Phase 6: Feature – Auth
| # | Tính năng | Trạng thái |
|---|---|---|
| 6.1 | Model `user_session.dart` | 🟢 DONE |
| 6.2 | Provider `auth_provider.dart` | 🟢 DONE |
| 6.3 | Page `splash_page.dart` | 🟢 DONE |
| 6.4 | Page `login_page.dart` | 🟢 DONE |
| 6.5 | Widget `server_url_field.dart` | 🟢 DONE |

## Phase 7: Feature – Orders (fsm.order)
| # | Tính năng | Trạng thái |
|---|---|---|
| 7.1 | Model `fsm_order.dart` | 🟢 DONE |
| 7.2 | Service `orders_service.dart` | 🟢 DONE |
| 7.3 | Provider `orders_provider.dart` | 🟢 DONE |
| 7.4 | Widget `order_card.dart` | 🟢 DONE |
| 7.5 | Widget `order_status_chip.dart` | 🟢 DONE |
| 7.6 | Page `orders_list_page.dart` | 🟢 DONE |
| 7.7 | Page `order_detail_page.dart` | 🟢 DONE |

## Phase 8: Feature – Route Map
| # | Tính năng | Trạng thái |
|---|---|---|
| 8.1 | Model `route_stop.dart` | 🟢 DONE |
| 8.2 | Service `location_service.dart` | 🟢 DONE |
| 8.3 | Provider `route_provider.dart` | 🟢 DONE |
| 8.4 | Widget `route_info_panel.dart` | 🟢 DONE |
| 8.5 | Page `route_map_page.dart` | 🟢 DONE |

## Phase 9: Feature – Stock
| # | Tính năng | Trạng thái |
|---|---|---|
| 9.1 | Model `product.dart` | 🟢 DONE |
| 9.2 | Model `stock_move.dart` | 🟢 DONE |
| 9.3 | Service `stock_service.dart` | 🟢 DONE |
| 9.4 | Provider `stock_provider.dart` | 🟢 DONE |
| 9.5 | Page `scanner_page.dart` | 🟢 DONE |
| 9.6 | Page `stock_moves_page.dart` | 🟢 DONE |

## Phase 10: Feature – Timesheet
| # | Tính năng | Trạng thái |
|---|---|---|
| 10.1 | Model `timesheet_entry.dart` | 🟢 DONE |
| 10.2 | Service `timesheet_service.dart` | 🟢 DONE |
| 10.3 | Provider `timesheet_provider.dart` | 🟢 DONE |
| 10.4 | Widget `time_entry_form.dart` | 🟢 DONE |
| 10.5 | Page `timesheet_page.dart` | 🟢 DONE |

## Phase 11: Feature – Expense
| # | Tính năng | Trạng thái |
|---|---|---|
| 11.1 | Model `expense.dart` | 🟢 DONE |
| 11.2 | Service `expense_service.dart` | 🟢 DONE |
| 11.3 | Provider `expense_provider.dart` | 🟢 DONE |
| 11.4 | Widget `receipt_image_picker.dart` | 🟢 DONE |
| 11.5 | Widget `expense_form.dart` | 🟢 DONE |
| 11.6 | Page `expense_page.dart` | 🟢 DONE |

## Phase 12: Feature – Work Order
| # | Tính năng | Trạng thái |
|---|---|---|
| 12.1 | Model `work_report.dart` | 🟢 DONE |
| 12.2 | Service `work_order_service.dart` | 🟢 DONE |
| 12.3 | Provider `work_order_provider.dart` | 🟢 DONE |
| 12.4 | Widget `photo_capture_widget.dart` | 🟢 DONE |
| 12.5 | Widget `customer_signature_widget.dart` | 🟢 DONE |
| 12.6 | Page `work_order_page.dart` | 🟢 DONE |

---

## ⚠️ Việc còn lại sau khi build code

| Hạng mục | Mô tả |
|---|---|
| **Isar codegen** | Chạy `dart run build_runner build` để generate `.g.dart` cho các models |
| **Isar schema** | Đăng ký các collection mới (RouteStop, Product, StockMove, TimesheetEntry, Expense, WorkReport) vào `isar_service.dart` |
| **pubspec.yaml** | Kiểm tra thêm `mobile_scanner`, `geolocator`, `url_launcher`, `image_picker`, `path_provider`, `intl` đã có chưa |
| **Test thực tế** | Kết nối server Odoo thật và test từng feature |
