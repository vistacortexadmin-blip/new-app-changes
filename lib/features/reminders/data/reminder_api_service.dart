import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/reminder.dart';

typedef ReminderAuthTokenProvider = Future<String?> Function();

class ReminderApiException implements Exception {
  final String message;
  const ReminderApiException(this.message);

  @override
  String toString() => 'ReminderApiException: $message';
}

/// Sends/receives reminders to/from the VistaCortex application backend.
/// Mirror of BackendReportAnalysisService — same http client, same Bearer
/// Firebase ID token, same fallback behaviour.
class ReminderApiService {
  final Uri baseUrl;
  final http.Client _client;
  final ReminderAuthTokenProvider? authTokenProvider;
  final Duration timeout;

  ReminderApiService({
    required this.baseUrl,
    http.Client? client,
    this.authTokenProvider,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await authTokenProvider?.call();
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    return headers;
  }

  // ---------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------
  Future<List<Reminder>> fetchAll() async {
    final res = await _client
        .get(baseUrl.replace(path: '${baseUrl.path}/reminders'),
            headers: await _headers())
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ReminderApiException(
          'GET reminders failed: HTTP ${res.statusCode}');
    }

    final body = jsonDecode(res.body);
    final list = body is Map ? body['data'] : body;
    if (list is! List) return const [];

    return list
        .whereType<Map>()
        .map((e) => Reminder.fromSupabase(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<Reminder> create(Reminder reminder) async {
    final res = await _client
        .post(
          baseUrl.replace(path: '${baseUrl.path}/reminders'),
          headers: await _headers(),
          body: jsonEncode(reminder.toSupabase()),
        )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ReminderApiException(
          'POST reminder failed: HTTP ${res.statusCode}');
    }

    final body = jsonDecode(res.body);
    final data = body is Map && body['data'] is Map
        ? Map<String, dynamic>.from(body['data'])
        : body is Map
            ? Map<String, dynamic>.from(body)
            : <String, dynamic>{};
    return Reminder.fromSupabase(data);
  }

  Future<void> update(Reminder reminder) async {
    final res = await _client
        .put(
          baseUrl.replace(path: '${baseUrl.path}/reminders/${reminder.id}'),
          headers: await _headers(),
          body: jsonEncode(reminder.toSupabase()),
        )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ReminderApiException('PUT reminder failed: HTTP ${res.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final res = await _client
        .delete(
          baseUrl.replace(path: '${baseUrl.path}/reminders/$id'),
          headers: await _headers(),
        )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ReminderApiException(
          'DELETE reminder failed: HTTP ${res.statusCode}');
    }
  }
}
