import 'dart:convert';

import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:web/web.dart' as web;

class ExpiringAuthSuccessStorage extends CachedClientAuthSuccessStorage {
  ExpiringAuthSuccessStorage({
    required Duration ttl,
    String? authSuccessStorageKey,
  }) : super(
          delegate: KeyValueClientAuthSuccessStorage(
            keyValueStorage: _ExpiringLocalStorage(ttl: ttl),
            authSuccessStorageKey: authSuccessStorageKey,
          ),
        );
}

class _ExpiringLocalStorage implements KeyValueStorage {
  _ExpiringLocalStorage({required this.ttl});

  final Duration ttl;

  @override
  Future<String?> get(String key) async {
    final stored = web.window.localStorage.getItem(key);
    if (stored == null) return null;

    try {
      final data = jsonDecode(stored);
      if (data is! Map<String, dynamic>) {
        await set(key, null);
        return null;
      }

      final expiresAt = data['expiresAt'];
      final value = data['value'];
      if (expiresAt is! int || value is! String) {
        await set(key, null);
        return null;
      }

      if (DateTime.now().millisecondsSinceEpoch >= expiresAt) {
        await set(key, null);
        return null;
      }

      return value;
    } catch (_) {
      await set(key, null);
      return null;
    }
  }

  @override
  Future<void> set(String key, String? value) async {
    if (value == null) {
      web.window.localStorage.removeItem(key);
      return;
    }

    final payload = jsonEncode({
      'value': value,
      'expiresAt': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
    web.window.localStorage.setItem(key, payload);
  }
}
