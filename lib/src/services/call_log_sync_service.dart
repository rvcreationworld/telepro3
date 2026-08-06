import 'dart:convert';

import 'package:call_log/call_log.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'session_store.dart';

enum SyncOutcome { disabled, nothingToSync, uploaded }

class CallLogSyncService {
  CallLogSyncService({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint = String.fromEnvironment('CALL_LOG_SYNC_URL');
  static const _syncedKey = 'synced_call_log_fingerprints';
  final http.Client _client;

  Future<SyncOutcome> sync(List<CallLogEntry> entries) async {
    if (_endpoint.isEmpty) return SyncOutcome.disabled;
    final preferences = await SharedPreferences.getInstance();
    final synced = preferences.getStringList(_syncedKey)?.toSet() ?? <String>{};
    final pending = entries
        .where((entry) => !synced.contains(_fingerprint(entry)))
        .toList();
    if (pending.isEmpty) return SyncOutcome.nothingToSync;

    final token = await SessionStore.authToken();
    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'content-type': 'application/json',
        if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
      },
      body: jsonEncode({'logs': pending.map(_toJson).toList(growable: false)}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dashboard sync failed (${response.statusCode})');
    }
    synced.addAll(pending.map(_fingerprint));
    const maxFingerprints = 3000;
    final compact = synced.length <= maxFingerprints
        ? synced.toList()
        : synced.skip(synced.length - maxFingerprints).toList();
    await preferences.setStringList(_syncedKey, compact);
    return SyncOutcome.uploaded;
  }

  Map<String, Object?> _toJson(CallLogEntry entry) => {
    'id': _fingerprint(entry),
    'number': entry.number,
    'normalizedNumber': normalizeNumber(entry.number ?? ''),
    'name': entry.name,
    'direction': entry.callType?.name,
    'startedAt': DateTime.fromMillisecondsSinceEpoch(
      entry.timestamp ?? 0,
      isUtc: true,
    ).toIso8601String(),
    'durationSeconds': entry.duration ?? 0,
  };

  String _fingerprint(CallLogEntry entry) =>
      '${normalizeNumber(entry.number ?? '')}|${entry.callType?.name}|${entry.timestamp}|${entry.duration}';

  static String normalizeNumber(String value) {
    final trimmed = value.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }
}
