import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/api/odoo_session_manager.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/settings/offline_storage_service.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/settings/sync_status_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../ui/theme/sf_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/services/orders_service.dart';

/// Connection state from a real session ping (no authenticate, no session overwrite).
enum _ConnStatus { unknown, valid, invalid, offline, expired }

const String _appVersion = '0.4.0';
const int _buildNumber = 12;
const String _supportEmail = 'mobile@acme.vn';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SyncStatusProvider _sync = SyncStatusProvider();

  _ConnStatus _connStatus = _ConnStatus.unknown;
  bool _isTesting = false;
  bool _isSyncing = false;
  bool _wifiOnly = false;
  Timer? _clockTimer;
  int _autoSync = 15;
  String _storageLabel = '...';

  @override
  void initState() {
    super.initState();
    _sync.addListener(_onSyncChanged);
    _load();
    // Đồng hồ 1 phút: tự vẽ lại để nhãn "Xm ago" nhảy + đọc lại last/pending.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!mounted) return;
      await _sync.refresh();
      if (mounted) setState(() {});
    });
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final repo = SettingsRepository.instance;
    await repo.loadAll();
    final storage = await OfflineStorageService.instance.formatted();
    if (!mounted) return;
    setState(() {
      _wifiOnly = repo.wifiOnly;
      _autoSync = repo.autoSyncMinutes;
      _storageLabel = storage;
    });
    await _sync.refresh();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _sync.removeListener(_onSyncChanged);
    _sync.dispose();
    super.dispose();
  }

  // ── Actions ──

  /// Ping session thật (đọc res.users của chính mình). KHÔNG authenticate,
  /// KHÔNG đè session — chỉ kiểm tra server + session còn sống.
  Future<void> _testConnection() async {
    final userId = OdooSessionManager.instance.currentUserId;
    if (userId == null) {
      setState(() => _connStatus = _ConnStatus.invalid);
      return;
    }
    setState(() => _isTesting = true);
    try {
      await OdooSessionManager.instance.callKw(
        model: 'res.users',
        method: 'read',
        args: [
          [userId]
        ],
        kwargs: {'fields': ['id']},
      );
      if (mounted) setState(() => _connStatus = _ConnStatus.valid);
    } on OdooConnectionException {
      if (mounted) setState(() => _connStatus = _ConnStatus.offline);
    } on OdooApiException {
      // Session hết hạn / access denied → coi như expired.
      if (mounted) setState(() => _connStatus = _ConnStatus.expired);
    } catch (_) {
      if (mounted) setState(() => _connStatus = _ConnStatus.offline);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  /// Sync thật: đẩy thay đổi local lên Odoo, rồi kéo đơn mới về, ghi last synced.
  Future<void> _onSyncNow() async {
    if (OdooSessionManager.instance.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not signed in.')),
      );
      return;
    }
    setState(() => _isSyncing = true);
    try {
      await OrdersService.instance.syncPending();
      await OrdersService.instance.fetchMyOrders();
      await SettingsRepository.instance.saveLastSyncedAt(DateTime.now());
      await _sync.refresh();
      if (!mounted) return;

      // Báo chính xác: còn bao nhiêu bản ghi chưa đẩy được (partial failure / offline).
      final stillPending = _sync.pendingCount;
      if (stillPending > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synced, but $stillPending change(s) still pending.'),
            backgroundColor: SfTokens.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synced successfully.')),
        );
      }
    } catch (e) {
      logger.e('_onSyncNow failed', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync failed — check connection.')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  /// Đăng xuất thật (AuthService.logout dọn SecureStorage + Odoo session) → về Login.
  Future<void> _onLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  // ── Helpers ──

  String get _lastSyncedLabel {
    final t = _sync.lastSyncedAt;
    if (t == null) return 'Never';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _statusColor(_ConnStatus s) {
    switch (s) {
      case _ConnStatus.valid:
        return SfTokens.success;
      case _ConnStatus.expired:
        return SfTokens.warning;
      case _ConnStatus.offline:
      case _ConnStatus.invalid:
        return SfTokens.error;
      case _ConnStatus.unknown:
        return SfTokens.onSurfaceWeak;
    }
  }

  String _statusText(_ConnStatus s) {
    switch (s) {
      case _ConnStatus.valid:
        return 'Connected';
      case _ConnStatus.expired:
        return 'Session expired';
      case _ConnStatus.offline:
        return 'Offline';
      case _ConnStatus.invalid:
        return 'Not signed in';
      case _ConnStatus.unknown:
        return 'Tap Test to check';
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SfTokens.background,
      appBar: AppBar(
        backgroundColor: SfTokens.primary,
        foregroundColor: SfTokens.surface,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SfTokens.spacingMd),
        children: [
          _buildConnection(),
          const SizedBox(height: SfTokens.spacingLg),
          _buildSyncOffline(),
          const SizedBox(height: SfTokens.spacingLg),
          _buildAccount(),
          const SizedBox(height: SfTokens.spacingLg),
          _buildAbout(),
          const SizedBox(height: SfTokens.spacingXl),
        ],
      ),
    );
  }

  Widget _buildConnection() {
    final session = OdooSessionManager.instance.currentSession;
    return _Card(
      title: 'Odoo Connection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoRow('Server', session?.serverUrl ?? '—'),
          _infoRow('Database', session?.database ?? '—'),
          _infoRow('User', session?.username ?? '—'),
          const SizedBox(height: SfTokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isTesting ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SfTokens.primary,
                    foregroundColor: SfTokens.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SfTokens.radiusSm),
                    ),
                  ),
                  child: _isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SfTokens.surface,
                          ),
                        )
                      : const Text('Test Connection'),
                ),
              ),
              const SizedBox(width: SfTokens.spacingSm),
              Icon(Icons.circle, size: 12, color: _statusColor(_connStatus)),
              const SizedBox(width: SfTokens.spacingXxs),
              Flexible(
                child: Text(
                  _statusText(_connStatus),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(_connStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SfTokens.spacingXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: SfTokens.onSurfaceWeak),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: SfTokens.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncOffline() {
    return _Card(
      title: 'Sync & Offline',
      child: Column(
        children: [
          _row(
            icon: Icons.sync,
            label: 'Sync now',
            trailing: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _onSyncNow,
                    icon: const Icon(Icons.refresh, color: SfTokens.primary),
                  ),
          ),
          const Divider(height: 1, color: SfTokens.divider),
          _row(
            icon: Icons.schedule,
            label: 'Last synced',
            value: _lastSyncedLabel,
          ),
          const Divider(height: 1, color: SfTokens.divider),
          _row(
            icon: _sync.hasPending ? Icons.cloud_upload : Icons.check_circle,
            iconColor: _sync.hasPending ? SfTokens.warning : SfTokens.success,
            label: _sync.hasPending
                ? '${_sync.pendingCount} changes pending upload'
                : 'All synced',
            labelColor: _sync.hasPending ? SfTokens.warning : SfTokens.success,
          ),
          const Divider(height: 1, color: SfTokens.divider),
          _row(
            icon: Icons.timer_outlined,
            label: 'Auto-sync',
            trailing: DropdownButton<int>(
              value: _autoSync,
              underline: const SizedBox.shrink(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _autoSync = v);
                SettingsRepository.instance.saveAutoSyncMinutes(v);
              },
              items: const [
                DropdownMenuItem(value: 0, child: Text('Off')),
                DropdownMenuItem(value: 5, child: Text('5 min')),
                DropdownMenuItem(value: 15, child: Text('15 min')),
                DropdownMenuItem(value: 30, child: Text('30 min')),
                DropdownMenuItem(value: 60, child: Text('60 min')),
              ],
            ),
          ),
          const Divider(height: 1, color: SfTokens.divider),
          _row(
            icon: Icons.wifi,
            label: 'Sync on WiFi only',
              trailing: Switch(
                value: _wifiOnly,
                activeThumbColor: SfTokens.primary,
                onChanged: (v) {
                  setState(() => _wifiOnly = v);
                  SettingsRepository.instance.saveWifiOnly(v);
                },
              ),
          ),
          const Divider(height: 1, color: SfTokens.divider),
          _row(
            icon: Icons.sd_storage_outlined,
            label: 'Offline data',
            value: _storageLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildAccount() {
    final session = OdooSessionManager.instance.currentSession;
    return _Card(
      title: 'Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle, color: SfTokens.primary, size: 32),
              const SizedBox(width: SfTokens.spacingSm),
              Expanded(
                child: Text(
                  session?.username ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SfTokens.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SfTokens.spacingSm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _onLogout,
              style: TextButton.styleFrom(foregroundColor: SfTokens.error),
              child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout() {
    return _Card(
      title: 'About',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fieldforce Mobile',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SfTokens.onSurface),
          ),
          const SizedBox(height: SfTokens.spacingXxs),
          Text(
            'Version $_appVersion (build $_buildNumber)',
            style: const TextStyle(fontSize: 13, color: SfTokens.onSurfaceWeak),
          ),
          const SizedBox(height: SfTokens.spacingXxs),
          Text(
            'Support: $_supportEmail',
            style: const TextStyle(fontSize: 13, color: SfTokens.onSurfaceWeak),
          ),
        ],
      ),
    );
  }

  // ── Row / Card helpers ──

  Widget _row({
    required IconData icon,
    Color? iconColor,
    required String label,
    Color? labelColor,
    String? value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SfTokens.spacingXs),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? SfTokens.onSurfaceWeak, size: SfTokens.iconSm),
          const SizedBox(width: SfTokens.spacingSm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor ?? SfTokens.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value != null)
            Text(value, style: const TextStyle(fontSize: 13, color: SfTokens.onSurfaceWeak)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SfTokens.spacingMd),
      decoration: BoxDecoration(
        color: SfTokens.surface,
        borderRadius: BorderRadius.circular(SfTokens.radiusMd),
        border: Border.all(color: SfTokens.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: SfTokens.onSurfaceWeak,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: SfTokens.spacingSm),
          child,
        ],
      ),
    );
  }
}