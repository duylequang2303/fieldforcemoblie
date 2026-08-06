import 'odoo_session_manager.dart';

/// Mixin helper to validate that the Odoo session has not changed
/// during in-flight asynchronous operations inside providers.
mixin SessionGuard {
  String? get currentSessionToken =>
      OdooSessionManager.instance.currentSession?.sessionId;

  bool isSameSession(String? token) => currentSessionToken == token;
}
