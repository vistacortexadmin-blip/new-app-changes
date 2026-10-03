import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:vistacortex_new_features/core/utils/trend_calculator.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/services/backend_report_analysis_service.dart';
import 'package:vistacortex_new_features/features/reports/services/report_analysis_service.dart';

void main() {
  late Directory temporaryDirectory;
  late File reportFile;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'vistacortex_backend_analysis_test_',
    );
    reportFile = File('${temporaryDirectory.path}/report.pdf');
    await reportFile.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('uploads a report and parses the structured analysis response',
      () async {
    final client = _RecordingClient(
      responseBody: jsonEncode({
        'analysis': {
          'parameters': [
            {
              'name': 'HbA1c',
              'value': 6.1,
              'unit': '%',
              'referenceRange': {'min': 4.0, 'max': 5.6},
              'status': 'borderlineHigh',
              'interpretation': 'Above the supplied laboratory range.',
            },
          ],
          'summaryPlainLanguage': 'HbA1c is above the reference range.',
          'questionsForDoctor': ['When should I repeat this test?'],
          'dietRecommendation': {
            'title': 'Glucose-conscious plan',
            'rationale': 'Linked to the extracted HbA1c result.',
            'foodsToEat': ['Non-starchy vegetables'],
            'foodsToAvoid': ['Sugary drinks'],
            'dailyMeals': [],
            'nutritionTip': 'Confirm this guidance with your clinician.',
          },
        },
      }),
    );
    final service = BackendReportAnalysisService(
      endpoint:
          Uri.parse('https://analysis.example.test/api/v1/reports/analyze'),
      client: client,
      authTokenProvider: () async => 'firebase-token',
    );

    final result = await service.analyzeDocument(
      documentPath: reportFile.path,
      documentType: ReportDocumentType.pdf,
      category: ReportCategory.diabeticPanel,
    );

    expect(client.method, 'POST');
    expect(client.authorization, 'Bearer firebase-token');
    expect(client.requestBody, contains('diabeticPanel'));
    expect(client.requestBody, contains('responseSchema'));
    expect(client.requestBody, contains('report.pdf'));
    expect(result.status, ReportAnalysisStatus.completed);
    expect(result.parameters.single.name, 'HbA1c');
    expect(result.parameters.single.status, ValueStatus.high);
    expect(result.summary, contains('above'));
    expect(result.questionsForDoctor, hasLength(1));
    expect(result.dietRecommendation?.title, 'Glucose-conscious plan');
  });

  test('accepts a string reference range and computes a missing status', () {
    final result = ReportAnalysisJsonParser.parse({
      'parameters': [
        {
          'name': 'LDL Cholesterol',
          'value': 145,
          'unit': 'mg/dL',
          'referenceRange': '0 - 100',
        },
      ],
      'summary': 'LDL cholesterol needs review.',
      'questionsForDoctor': [],
    });

    expect(result.parameters.single.minNormal, 0);
    expect(result.parameters.single.maxNormal, 100);
    expect(result.parameters.single.status, ValueStatus.criticalHigh);
  });

  test('uses on-device analysis when the backend is unavailable', () async {
    const expected = ReportAnalysisResult(
      parameters: [],
      summary: 'Offline analysis result',
      questionsForDoctor: [],
      dietRecommendation: null,
      status: ReportAnalysisStatus.noValuesFound,
    );
    final service = FallbackReportAnalysisService(
      primary: _ThrowingAnalysisService(),
      fallback: const _ResultAnalysisService(expected),
    );

    final result = await service.analyzeDocument(
      documentPath: reportFile.path,
      documentType: ReportDocumentType.pdf,
      category: ReportCategory.generalCheckup,
    );

    expect(result.summary, 'Offline analysis result');
  });
}

class _RecordingClient extends http.BaseClient {
  final String responseBody;
  String? method;
  String? authorization;
  String requestBody = '';

  _RecordingClient({required this.responseBody});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    method = request.method;
    authorization = request.headers[HttpHeaders.authorizationHeader];
    requestBody = latin1.decode(await request.finalize().toBytes());
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

class _ThrowingAnalysisService implements ReportAnalysisService {
  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) {
    throw const BackendReportAnalysisException('Backend unavailable.');
  }
}

class _ResultAnalysisService implements ReportAnalysisService {
  final ReportAnalysisResult result;

  const _ResultAnalysisService(this.result);

  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) async =>
      result;
}
