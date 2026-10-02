import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/utils/trend_calculator.dart';
import '../models/report_model.dart';
import 'report_analysis_service.dart';

typedef AnalysisAuthTokenProvider = Future<String?> Function();

class BackendReportAnalysisException implements Exception {
  final String message;

  const BackendReportAnalysisException(this.message);

  @override
  String toString() => 'BackendReportAnalysisException: $message';
}

/// Sends the original report to a secure application backend. The backend can
/// call Gemini or another clinical extraction service without putting its API
/// key in the mobile application.
class BackendReportAnalysisService implements ReportAnalysisService {
  static const int _maxResponseBytes = 1024 * 1024;

  final Uri endpoint;
  final http.Client _client;
  final AnalysisAuthTokenProvider? authTokenProvider;
  final Duration timeout;

  BackendReportAnalysisService({
    required this.endpoint,
    http.Client? client,
    this.authTokenProvider,
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) async {
    final document = File(documentPath);
    if (!await document.exists()) {
      throw const BackendReportAnalysisException('Report file not found.');
    }

    final request = http.MultipartRequest('POST', endpoint)
      ..fields['documentType'] = documentType.name
      ..fields['category'] = category.name
      ..fields['responseSchemaVersion'] = '1'
      ..fields['responseSchema'] = jsonEncode(_responseSchema)
      ..files.add(
        await http.MultipartFile.fromPath(
          'report',
          documentPath,
          filename: document.uri.pathSegments.last,
        ),
      );

    final token = await authTokenProvider?.call();
    if (token != null && token.trim().isNotEmpty) {
      request.headers[HttpHeaders.authorizationHeader] =
          'Bearer ${token.trim()}';
    }
    request.headers[HttpHeaders.acceptHeader] = 'application/json';

    final response = await _client.send(request).timeout(timeout);
    final bytes = await response.stream.toBytes().timeout(timeout);
    if (bytes.length > _maxResponseBytes) {
      throw const BackendReportAnalysisException(
        'Analysis response exceeded the allowed size.',
      );
    }
    final body = utf8.decode(bytes, allowMalformed: false);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendReportAnalysisException(
        'Analysis service returned HTTP ${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('Response must be a JSON object.');
      }
      return ReportAnalysisJsonParser.parse(
        Map<String, dynamic>.from(decoded),
      );
    } on BackendReportAnalysisException {
      rethrow;
    } on Object catch (error) {
      throw BackendReportAnalysisException(
        'Invalid structured analysis response: $error',
      );
    }
  }

  static const Map<String, Object> _responseSchema = {
    'parameters': [
      {
        'name': 'string',
        'value': 'number',
        'unit': 'string',
        'referenceRange': {'min': 'number', 'max': 'number'},
        'status':
            'normal|borderlineLow|borderlineHigh|criticalLow|criticalHigh',
        'interpretation': 'string',
      },
    ],
    'summaryPlainLanguage': 'string',
    'questionsForDoctor': ['string'],
    'dietRecommendation': {
      'title': 'string',
      'rationale': 'string',
      'foodsToEat': ['string'],
      'foodsToAvoid': ['string'],
      'dailyMeals': [
        {
          'mealType': 'string',
          'recommendedFood': 'string',
          'benefits': 'string',
          'nutrition': 'string',
        },
      ],
      'nutritionTip': 'string',
    },
  };
}

class FallbackReportAnalysisService implements ReportAnalysisService {
  final ReportAnalysisService primary;
  final ReportAnalysisService fallback;

  const FallbackReportAnalysisService({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) async {
    try {
      return await primary.analyzeDocument(
        documentPath: documentPath,
        documentType: documentType,
        category: category,
      );
    } catch (_) {
      return fallback.analyzeDocument(
        documentPath: documentPath,
        documentType: documentType,
        category: category,
      );
    }
  }
}

class ReportAnalysisJsonParser {
  const ReportAnalysisJsonParser._();

  static ReportAnalysisResult parse(Map<String, dynamic> response) {
    final analysisValue = response['analysis'];
    final root = analysisValue is Map
        ? Map<String, dynamic>.from(analysisValue)
        : response;
    final rawParameters = root['parameters'];
    if (rawParameters is! List) {
      throw const BackendReportAnalysisException(
        'The parameters array is missing.',
      );
    }

    final parameters = <TestParameter>[];
    for (var index = 0; index < rawParameters.length; index++) {
      final raw = rawParameters[index];
      if (raw is! Map) continue;
      final json = Map<String, dynamic>.from(raw);
      final name = json['name']?.toString().trim() ?? '';
      final value = _asDouble(json['value']);
      final range = _referenceRange(json);
      if (name.isEmpty || value == null || range == null) continue;

      parameters.add(
        TestParameter(
          id: json['id']?.toString() ??
              'backend_${index}_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
          name: name,
          value: value,
          unit: json['unit']?.toString().trim() ?? '',
          minNormal: range.$1,
          maxNormal: range.$2,
          status: _status(json['status']) ??
              TrendCalculator.evaluateStatus(value, range.$1, range.$2),
          interpretation: json['interpretation']?.toString(),
        ),
      );
    }

    if (parameters.isEmpty) {
      return ReportAnalysisResult(
        parameters: const [],
        summary: _string(root['summaryPlainLanguage'] ?? root['summary']) ??
            'No supported structured biomarkers were returned by the analysis service.',
        questionsForDoctor: const [],
        dietRecommendation: null,
        status: ReportAnalysisStatus.noValuesFound,
      );
    }

    final questions = (root['questionsForDoctor'] as List? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final dietValue = root['dietRecommendation'];
    return ReportAnalysisResult(
      parameters: parameters,
      summary: _string(root['summaryPlainLanguage'] ?? root['summary']) ??
          '${parameters.length} biomarkers were extracted for review.',
      questionsForDoctor: questions,
      dietRecommendation: dietValue is Map
          ? DietRecommendation.fromJson(Map<String, dynamic>.from(dietValue))
          : null,
      status: ReportAnalysisStatus.completed,
    );
  }

  static (double, double)? _referenceRange(Map<String, dynamic> json) {
    final raw = json['referenceRange'];
    double? min;
    double? max;
    if (raw is Map) {
      min = _asDouble(raw['min'] ?? raw['minimum']);
      max = _asDouble(raw['max'] ?? raw['maximum']);
    } else if (raw is String) {
      final match = RegExp(
        r'(-?\d+(?:\.\d+)?)\s*(?:-|to)\s*(-?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ).firstMatch(raw);
      min = _asDouble(match?.group(1));
      max = _asDouble(match?.group(2));
    }
    min ??= _asDouble(json['minNormal']);
    max ??= _asDouble(json['maxNormal']);
    if (min == null || max == null || !min.isFinite || !max.isFinite) {
      return null;
    }
    if (max <= min) return null;
    return (min, max);
  }

  static ValueStatus? _status(Object? raw) {
    final normalized =
        raw?.toString().replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    return switch (normalized) {
      'normal' => ValueStatus.normal,
      'low' || 'borderlinelow' => ValueStatus.low,
      'high' || 'borderlinehigh' => ValueStatus.high,
      'criticallow' => ValueStatus.criticalLow,
      'criticalhigh' => ValueStatus.criticalHigh,
      _ => null,
    };
  }

  static double? _asDouble(Object? value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    return number?.isFinite == true ? number : null;
  }

  static String? _string(Object? value) {
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }
}
