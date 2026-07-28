import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/auth/secure_storage.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/settings/offline_storage_service.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/settings/sync_status_provider.dart';
import '../../../../ui/theme/sf_tokens.dart';
import '../../auth/providers/auth_provider.dart';

/// Connection check state (no server ping yet — format validation only).
enum _ConnStatus { unknown, valid, invalid }

const String _appVersion = '0.4.0';
const int _buildNumber = 12;
const String _supportEmail = 'mobile@acme.vn';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _urlCtrl = TextEditingController();
  final _dbCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();

  final SyncStatusProvider _sync = SyncStatusProvider();

  _ConnStatus _connStatus = _ConnStatus.unknown;
  bool _wifiOnly = false;
  int _autoSync = 15;
  String _storageLabel = '...';
  String _accountName = '';

  @override
  void initState() {
    super.initState();
    _sync.addListener(_onSyncChanged);
    _load();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final repo = SettingsRepository.instance;
    await repo.loadAll();

    // Account name: read-only from the current login session.
    String name = '';
    try {
      final creds = await SecureStorageService.instance.loadSavedCredentials();
      name = creds['username'] ?? '';
    } catch (_) {}

    final storage = await OfflineStorageService.instance.formatted();

    if (!mounted) return;
    setState(() {
      _urlCtrl.text = repo.serverUrl;
      _dbCtrl.text = repo.database;
      _userCtrl.text = repo.username;
      _keyCtrl.text = repo.password;
      _wifiOnly = repo.wifiOnly;
      _autoSync = repo.autoSyncMinutes;
      _accountName = name;
      _storageLabel = storage;
      _connStatus = repo.hasConnection
          ? _ConnStatus.unknown
          : _ConnStatus.invalid;
    });
    await _sync.refresh();
  }

  @override
  void dispose() {
    _sync.removeListener(_onSyncChanged);
    _sync.dispose();
    _urlCtrl.dispose();
    _dbCtrl.dispose();
    _userCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──

  void _testConnection() {
    final url = _urlCtrl.text.trim();
    final okUrl =
        (url.startsWith('https://') || url.startsWith('http://')) &&
        url.length > 8;
    final ok = okUrl &&
        _dbCtrl.text.trim().isNotEmpty &&
        _userCtrl.text.trim().isNotEmpty &&
        _keyCtrl.text.trim().isNotEmpty;

    setState(() => _connStatus = ok ? _ConnStatus.valid : _ConnStatus.invalid);

    if (ok) {
      SettingsRepository.instance.saveConnection(
        serverUrl: url,
        database: _dbCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        password: _keyCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Config saved. Real connection arrives in Slice 5.')),
      );
    }
  }

  Future<void> _onSyncNow() async {
    if (!SettingsRepository.instance.hasConnection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter and test the Odoo connection first.')),
      );
      return;
    }
    await _sync.syncNow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulated sync. Real sync arrives in Slice 7.')),
    );
  }

  Future<void> _onLogout() async {
    final auth = context.read<AuthProvider>();
    await SettingsRepository.instance.clearConnection();
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
      case _ConnStatus.invalid:
        return SfTokens.error;
      case _ConnStatus.unknown:
        return SfTokens.onSurfaceWeak;
    }
  }

  String _statusText(_ConnStatus s) {
    switch (s) {
      case _ConnStatus.valid:
        return 'Valid (saved)';
      case _ConnStatus.invalid:
        return 'Missing info';
      case _ConnStatus.unknown:
        return 'Saved — tap Test to confirm';
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
    return _Card(
      title: 'Odoo Connection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_urlCtrl, 'Server URL', Icons.link, false),
          const SizedBox(height: SfTokens.spacingXs),
          _field(_dbCtrl, 'Database', Icons.storage_outlined, false),
          const SizedBox(height: SfTokens.spacingXs),
          _field(_userCtrl, 'Username', Icons.person_outline, false),
          const SizedBox(height: SfTokens.spacingXs),
          _field(_keyCtrl, 'Password', Icons.lock_outline, true),
          const SizedBox(height: SfTokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SfTokens.primary,
                    foregroundColor: SfTokens.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SfTokens.radiusSm),
                    ),
                  ),
                  child: const Text('Test Connection'),
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

  Widget _field(TextEditingController c, String label, IconData icon, bool obscure) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: SfTokens.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: SfTokens.onSurfaceWeak),
        filled: true,
        fillColor: SfTokens.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SfTokens.spacingSm,
          vertical: SfTokens.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
          borderSide: const BorderSide(color: SfTokens.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
          borderSide: const BorderSide(color: SfTokens.divider),
        ),
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
            trailing: _sync.isSyncing
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
              activeColor: SfTokens.primary,
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
                  _accountName.isEmpty ? 'Unknown' : _accountName,
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