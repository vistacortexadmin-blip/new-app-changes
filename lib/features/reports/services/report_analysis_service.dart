import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/utils/trend_calculator.dart';
import '../models/report_model.dart';

class ReportAnalysisResult {
  final List<TestParameter> parameters;
  final String summary;
  final List<String> questionsForDoctor;
  final DietRecommendation? dietRecommendation;
  final ReportAnalysisStatus status;

  const ReportAnalysisResult({
    required this.parameters,
    required this.summary,
    required this.questionsForDoctor,
    required this.dietRecommendation,
    required this.status,
  });
}

abstract class ReportAnalysisService {
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  });
}

abstract class ReportTextExtractor {
  Future<String> extractText({
    required String documentPath,
    required ReportDocumentType documentType,
  });
}

class LocalReportAnalysisService implements ReportAnalysisService {
  final ReportTextExtractor _textExtractor;
  final BiomarkerAnalysisEngine _analysisEngine;

  LocalReportAnalysisService({
    ReportTextExtractor? textExtractor,
    BiomarkerAnalysisEngine? analysisEngine,
  })  : _textExtractor = textExtractor ?? MlKitReportTextExtractor(),
        _analysisEngine = analysisEngine ?? const BiomarkerAnalysisEngine();

  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) async {
    final text = await _textExtractor.extractText(
      documentPath: documentPath,
      documentType: documentType,
    );
    return _analysisEngine.analyzeText(text, category: category);
  }
}

class MlKitReportTextExtractor implements ReportTextExtractor {
  static const int maxPdfPagesToAnalyze = 8;

  @override
  Future<String> extractText({
    required String documentPath,
    required ReportDocumentType documentType,
  }) async {
    if (documentType == ReportDocumentType.none) return '';

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      if (documentType == ReportDocumentType.image) {
        return _recognizeImage(recognizer, documentPath);
      }
      return _recognizePdf(recognizer, documentPath);
    } finally {
      await recognizer.close();
    }
  }

  Future<String> _recognizeImage(
    TextRecognizer recognizer,
    String path,
  ) async {
    final recognized = await recognizer.processImage(
      InputImage.fromFilePath(path),
    );
    return _orderedText(recognized);
  }

  Future<String> _recognizePdf(
    TextRecognizer recognizer,
    String path,
  ) async {
    final document = await PdfDocument.openFile(path);
    final temporaryRoot = await getTemporaryDirectory();
    final renderDirectory = await Directory(
      '${temporaryRoot.path}${Platform.pathSeparator}vistacortex_analysis_${DateTime.now().microsecondsSinceEpoch}',
    ).create(recursive: true);
    final pages = <String>[];

    try {
      final pageCount = math.min(document.pagesCount, maxPdfPagesToAnalyze);
      for (var pageNumber = 1; pageNumber <= pageCount; pageNumber++) {
        final page = await document.getPage(pageNumber);
        try {
          final scale = math.min(2.2, 2200 / page.width);
          final rendered = await page.render(
            width: page.width * scale,
            height: page.height * scale,
            format: PdfPageImageFormat.jpeg,
            quality: 92,
            backgroundColor: '#FFFFFF',
          );
          if (rendered == null) continue;
          final imageFile = File(
            '${renderDirectory.path}${Platform.pathSeparator}page_$pageNumber.jpg',
          );
          await imageFile.writeAsBytes(rendered.bytes, flush: true);
          final recognized = await recognizer.processImage(
            InputImage.fromFilePath(imageFile.path),
          );
          pages.add(_orderedText(recognized));
        } finally {
          await page.close();
        }
      }
    } finally {
      await document.close();
      if (await renderDirectory.exists()) {
        await renderDirectory.delete(recursive: true);
      }
    }
    return pages.join('\n');
  }

  String _orderedText(RecognizedText recognized) {
    final lines = <_PositionedText>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        lines.add(_PositionedText(line.text, line.boundingBox));
      }
    }
    if (lines.isEmpty) return recognized.text;

    lines.sort((a, b) {
      final vertical = a.centerY.compareTo(b.centerY);
      return vertical != 0 ? vertical : a.bounds.left.compareTo(b.bounds.left);
    });

    final rows = <List<_PositionedText>>[];
    for (final line in lines) {
      if (rows.isEmpty) {
        rows.add([line]);
        continue;
      }
      final row = rows.last;
      final rowCenter =
          row.map((item) => item.centerY).reduce((a, b) => a + b) / row.length;
      final tolerance = math.max(10.0, line.bounds.height * 0.65);
      if ((line.centerY - rowCenter).abs() <= tolerance) {
        row.add(line);
      } else {
        rows.add([line]);
      }
    }

    return rows.map((row) {
      row.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
      return row.map((item) => item.text).join(' ');
    }).join('\n');
  }
}

class _PositionedText {
  final String text;
  final Rect bounds;

  const _PositionedText(this.text, this.bounds);

  double get centerY => bounds.top + (bounds.height / 2);
}

class BiomarkerAnalysisEngine {
  const BiomarkerAnalysisEngine();

  ReportAnalysisResult analyzeText(
    String rawText, {
    required ReportCategory category,
  }) {
    final parameters = _parseParameters(rawText);
    if (parameters.isEmpty) {
      return const ReportAnalysisResult(
        parameters: [],
        summary:
            'No supported structured biomarkers were detected. Review the original report and retry with a clear, upright document.',
        questionsForDoctor: [],
        dietRecommendation: null,
        status: ReportAnalysisStatus.noValuesFound,
      );
    }

    final summary = _buildSummary(parameters);
    final questions = _buildQuestions(parameters);
    final diet = _buildDietRecommendation(parameters, category);
    return ReportAnalysisResult(
      parameters: parameters,
      summary: summary,
      questionsForDoctor: questions,
      dietRecommendation: diet,
      status: ReportAnalysisStatus.completed,
    );
  }

  List<TestParameter> _parseParameters(String rawText) {
    final cleaned = rawText
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2212', '-')
        .replaceAll(RegExp(r'[ \t]+'), ' ');
    final lines = cleaned
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final parameters = <TestParameter>[];

    for (final spec in _biomarkers) {
      _ParsedCandidate? best;
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        final lower = line.toLowerCase();
        for (final alias in spec.aliases) {
          final aliasIndex = lower.indexOf(alias);
          if (aliasIndex < 0) continue;

          var candidateText = line.substring(aliasIndex + alias.length);
          if (!_containsNumber(candidateText) && index + 1 < lines.length) {
            candidateText = '$candidateText ${lines[index + 1]}';
          }
          final candidate = _candidateFromText(candidateText, spec);
          if (candidate != null &&
              (best == null || candidate.score > best.score)) {
            best = candidate;
          }
        }
      }
      if (best == null) continue;

      final status = TrendCalculator.evaluateStatus(
        best.value,
        best.minNormal,
        best.maxNormal,
      );
      parameters.add(
        TestParameter(
          id: 'extracted_${spec.key}',
          name: spec.name,
          value: best.value,
          unit: spec.unit,
          minNormal: best.minNormal,
          maxNormal: best.maxNormal,
          status: status,
          interpretation: _interpretation(spec.name, status),
        ),
      );
    }
    return parameters;
  }

  _ParsedCandidate? _candidateFromText(
    String text,
    _BiomarkerSpec spec,
  ) {
    final numericMatches = _numberPattern.allMatches(text).toList();
    if (numericMatches.isEmpty) return null;
    final value = _number(numericMatches.first.group(0));
    if (value == null || value < 0 || value > spec.maxPlausible) return null;

    var minNormal = spec.minNormal;
    var maxNormal = spec.maxNormal;
    var hasExtractedRange = false;
    final tail = text.substring(numericMatches.first.end);
    final range = _rangePattern.firstMatch(tail);
    if (range != null) {
      final extractedMin = _number(range.group(1));
      final extractedMax = _number(range.group(2));
      if (extractedMin != null &&
          extractedMax != null &&
          extractedMax > extractedMin) {
        minNormal = extractedMin;
        maxNormal = extractedMax;
        hasExtractedRange = true;
      }
    }

    return _ParsedCandidate(
      value: value,
      minNormal: minNormal,
      maxNormal: maxNormal,
      score: (hasExtractedRange ? 10 : 0) + math.min(5, numericMatches.length),
    );
  }

  String _buildSummary(List<TestParameter> parameters) {
    final abnormal = parameters
        .where((parameter) => parameter.status != ValueStatus.normal)
        .toList();
    if (abnormal.isEmpty) {
      return '${parameters.length} supported biomarker${parameters.length == 1 ? '' : 's'} were extracted, and each is within the reference range printed on the report.';
    }

    final critical = abnormal
        .where((parameter) => TrendCalculator.isCritical(parameter.status))
        .toList();
    final details = abnormal.take(3).map((parameter) {
      return '${parameter.name} is ${TrendCalculator.getStatusLabel(parameter.status).toLowerCase()} at ${_format(parameter.value)} ${parameter.unit}';
    }).join('; ');
    final prefix = critical.isEmpty
        ? '${abnormal.length} extracted value${abnormal.length == 1 ? '' : 's'} fall outside the printed reference range'
        : '${critical.length} extracted value${critical.length == 1 ? '' : 's'} appear critically outside the printed reference range';
    return '$prefix: $details. Confirm these OCR results against the original document and discuss them with a clinician.';
  }

  List<String> _buildQuestions(List<TestParameter> parameters) {
    final abnormal = parameters
        .where((parameter) => parameter.status != ValueStatus.normal)
        .toList()
      ..sort((a, b) {
        final aCritical = TrendCalculator.isCritical(a.status) ? 0 : 1;
        final bCritical = TrendCalculator.isCritical(b.status) ? 0 : 1;
        return aCritical.compareTo(bCritical);
      });
    final questions = abnormal.take(4).map((parameter) {
      return 'My ${parameter.name} was extracted as ${_format(parameter.value)} ${parameter.unit} (${TrendCalculator.getStatusLabel(parameter.status)}). Is this accurate, and what follow-up do you recommend?';
    }).toList();
    questions.add(
      'When should these biomarkers be repeated, and are there symptoms that should prompt earlier medical review?',
    );
    return questions;
  }

  DietRecommendation _buildDietRecommendation(
    List<TestParameter> parameters,
    ReportCategory category,
  ) {
    final abnormal = parameters
        .where((parameter) => parameter.status != ValueStatus.normal)
        .toList();
    final names =
        abnormal.map((parameter) => parameter.name.toLowerCase()).toSet();
    final lipidConcern = names.any((name) =>
        name.contains('cholesterol') || name.contains('triglyceride'));
    final glucoseConcern =
        names.any((name) => name.contains('glucose') || name.contains('hba1c'));
    final bloodConcern = names.any((name) =>
        name.contains('hemoglobin') ||
        name.contains('ferritin') ||
        name.contains('rbc'));
    final kidneyOrSodiumConcern = names.any((name) =>
        name.contains('creatinine') ||
        name.contains('egfr') ||
        name.contains('sodium'));

    final include = <String>[];
    final avoid = <String>[];
    final rationales = <String>[];

    if (lipidConcern) {
      rationales.add('lipid values outside their printed range');
      include.addAll([
        'Oats, barley, beans and other soluble-fiber foods',
        'Unsalted nuts, seeds, olive oil and fish if appropriate',
      ]);
      avoid.addAll([
        'Deep-fried foods and products containing trans fats',
        'Processed meats and frequent high-saturated-fat meals',
      ]);
    }
    if (glucoseConcern) {
      rationales.add('glucose-related values outside their printed range');
      include.addAll([
        'Non-starchy vegetables with each main meal',
        'Measured portions of whole grains paired with protein',
        'Whole fruit instead of juice',
      ]);
      avoid.addAll([
        'Sugary drinks, sweets and sweetened breakfast cereals',
        'Large portions of refined flour or white rice',
      ]);
    }
    if (bloodConcern) {
      rationales.add('blood or iron markers outside their printed range');
      include.addAll([
        'Lentils, beans, leafy greens, eggs or clinician-approved lean protein',
        'Vitamin-C-rich foods alongside plant iron sources',
      ]);
      avoid.add(
        'Tea or coffee immediately alongside iron-rich meals',
      );
    }
    if (kidneyOrSodiumConcern) {
      rationales
          .add('kidney or electrolyte values outside their printed range');
      include.add(
        'Fresh home-cooked meals with sodium portions reviewed by a clinician',
      );
      avoid.addAll([
        'Packaged high-sodium foods',
        'Unsupervised protein, electrolyte or herbal supplements',
      ]);
    }

    if (include.isEmpty) {
      include.addAll([
        'Seasonal vegetables and whole fruits',
        'Beans, dal, eggs or another suitable lean protein',
        'Whole grains, unsalted nuts and water',
      ]);
      avoid.addAll([
        'Frequent ultra-processed or deep-fried foods',
        'Excess sugary drinks and high-sodium snacks',
      ]);
    }

    final focus = rationales.isEmpty
        ? 'the extracted biomarkers that are within their printed ranges'
        : rationales.join(', ');
    final meals = _mealsForFindings(
      lipidConcern: lipidConcern,
      glucoseConcern: glucoseConcern,
      bloodConcern: bloodConcern,
      kidneyOrSodiumConcern: kidneyOrSodiumConcern,
    );
    return DietRecommendation(
      title: rationales.isEmpty
          ? 'Maintenance plan based on extracted values'
          : 'Nutrition priorities from this report',
      rationale:
          'This guidance was generated from $focus. It is educational and should be adjusted for allergies, medications, diagnoses and clinician instructions.',
      foodsToEat: _unique(include),
      foodsToAvoid: _unique(avoid),
      dailyMeals: meals,
      nutritionTip: kidneyOrSodiumConcern
          ? 'Do not change fluid, sodium, potassium or protein intake without clinician guidance when kidney or heart conditions are possible.'
          : 'Use the original report and your clinician\'s advice as the source of truth; OCR-derived guidance can be incomplete.',
    );
  }

  List<DietMeal> _mealsForFindings({
    required bool lipidConcern,
    required bool glucoseConcern,
    required bool bloodConcern,
    required bool kidneyOrSodiumConcern,
  }) {
    final breakfast = glucoseConcern
        ? const DietMeal(
            mealType: 'Breakfast',
            recommendedFood:
                'Vegetable omelette or unsweetened yogurt with a small whole-grain portion',
            benefits: 'Pairs carbohydrate with protein and fiber.',
            nutrition: 'Protein, fiber and controlled carbohydrate',
          )
        : lipidConcern
            ? const DietMeal(
                mealType: 'Breakfast',
                recommendedFood:
                    'Oats with fruit, chia seeds and unsalted nuts',
                benefits: 'Adds soluble fiber and unsaturated fat.',
                nutrition: 'Soluble fiber and omega-rich fats',
              )
            : const DietMeal(
                mealType: 'Breakfast',
                recommendedFood:
                    'Vegetable upma or oats with fruit and a protein source',
                benefits:
                    'Provides a balanced start without excess added sugar.',
                nutrition: 'Whole grains, produce and protein',
              );
    final lunch = bloodConcern
        ? const DietMeal(
            mealType: 'Lunch',
            recommendedFood:
                'Lentils with leafy greens, roti or brown rice, and a vitamin-C-rich salad',
            benefits: 'Combines plant iron, folate, protein and vitamin C.',
            nutrition: 'Iron, folate, vitamin C and protein',
          )
        : const DietMeal(
            mealType: 'Lunch',
            recommendedFood:
                'Half a plate of vegetables with dal or lean protein and a whole grain',
            benefits: 'Balances fiber, protein and energy portions.',
            nutrition: 'Fiber-rich balanced plate',
          );
    const snack = DietMeal(
      mealType: 'Evening snack',
      recommendedFood: 'Whole fruit with unsalted nuts or roasted chana',
      benefits: 'Replaces refined snacks with fiber and protein.',
      nutrition: 'Fiber, protein and unsaturated fats',
    );
    final dinner = DietMeal(
      mealType: 'Dinner',
      recommendedFood: kidneyOrSodiumConcern
          ? 'Home-cooked vegetables with a clinician-approved protein and minimal added salt'
          : 'Vegetables with dal, tofu, paneer or fish and a modest whole-grain portion',
      benefits: kidneyOrSodiumConcern
          ? 'Keeps sodium visible and avoids unreviewed supplements.'
          : 'Provides vegetables and protein in a lighter evening meal.',
      nutrition: kidneyOrSodiumConcern
          ? 'Lower-sodium pattern requiring clinical personalization'
          : 'Vegetables, protein and whole-food carbohydrate',
    );
    return [breakfast, lunch, snack, dinner];
  }

  String _interpretation(String name, ValueStatus status) {
    switch (status) {
      case ValueStatus.normal:
        return '$name is within the reference range extracted from the report.';
      case ValueStatus.low:
        return '$name is below the extracted reference range and should be confirmed against the original report.';
      case ValueStatus.high:
        return '$name is above the extracted reference range and should be reviewed with a clinician.';
      case ValueStatus.criticalLow:
        return '$name appears substantially below the extracted range. Verify the OCR result and seek prompt clinical advice.';
      case ValueStatus.criticalHigh:
        return '$name appears substantially above the extracted range. Verify the OCR result and seek prompt clinical advice.';
    }
  }

  static bool _containsNumber(String value) => _numberPattern.hasMatch(value);

  static double? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', ''));

  static String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  static List<String> _unique(List<String> values) =>
      values.toSet().toList(growable: false);

  static final RegExp _numberPattern = RegExp(r'\d[\d,]*(?:\.\d+)?');
  static final RegExp _rangePattern = RegExp(
    r'(\d[\d,]*(?:\.\d+)?)\s*(?:-|to)\s*(\d[\d,]*(?:\.\d+)?)',
    caseSensitive: false,
  );
}

class _ParsedCandidate {
  final double value;
  final double minNormal;
  final double maxNormal;
  final int score;

  const _ParsedCandidate({
    required this.value,
    required this.minNormal,
    required this.maxNormal,
    required this.score,
  });
}

class _BiomarkerSpec {
  final String key;
  final String name;
  final List<String> aliases;
  final String unit;
  final double minNormal;
  final double maxNormal;
  final double maxPlausible;

  const _BiomarkerSpec({
    required this.key,
    required this.name,
    required this.aliases,
    required this.unit,
    required this.minNormal,
    required this.maxNormal,
    required this.maxPlausible,
  });
}

const _biomarkers = <_BiomarkerSpec>[
  _BiomarkerSpec(
    key: 'hemoglobin',
    name: 'Hemoglobin',
    aliases: ['hemoglobin', 'haemoglobin', 'hgb'],
    unit: 'g/dL',
    minNormal: 12,
    maxNormal: 16,
    maxPlausible: 30,
  ),
  _BiomarkerSpec(
    key: 'hematocrit',
    name: 'Hematocrit',
    aliases: ['hematocrit', 'haematocrit', 'hct'],
    unit: '%',
    minNormal: 36,
    maxNormal: 46,
    maxPlausible: 80,
  ),
  _BiomarkerSpec(
    key: 'rbc',
    name: 'RBC Count',
    aliases: ['rbc count', 'red blood cell count'],
    unit: 'million/uL',
    minNormal: 4,
    maxNormal: 5.2,
    maxPlausible: 12,
  ),
  _BiomarkerSpec(
    key: 'wbc',
    name: 'WBC Count',
    aliases: ['wbc count', 'white blood cell count', 'total leucocyte'],
    unit: 'thousand/uL',
    minNormal: 4,
    maxNormal: 11,
    maxPlausible: 100,
  ),
  _BiomarkerSpec(
    key: 'platelets',
    name: 'Platelet Count',
    aliases: ['platelet count', 'platelets'],
    unit: 'thousand/uL',
    minNormal: 150,
    maxNormal: 450,
    maxPlausible: 1500000,
  ),
  _BiomarkerSpec(
    key: 'ferritin',
    name: 'Ferritin',
    aliases: ['serum ferritin', 'ferritin'],
    unit: 'ng/mL',
    minNormal: 30,
    maxNormal: 300,
    maxPlausible: 5000,
  ),
  _BiomarkerSpec(
    key: 'glucose',
    name: 'Fasting Glucose',
    aliases: ['fasting blood glucose', 'fasting glucose', 'blood glucose'],
    unit: 'mg/dL',
    minNormal: 70,
    maxNormal: 99,
    maxPlausible: 1000,
  ),
  _BiomarkerSpec(
    key: 'hba1c',
    name: 'HbA1c',
    aliases: ['glycated hemoglobin', 'hba1c', 'hb a1c'],
    unit: '%',
    minNormal: 4,
    maxNormal: 5.6,
    maxPlausible: 25,
  ),
  _BiomarkerSpec(
    key: 'total_cholesterol',
    name: 'Total Cholesterol',
    aliases: ['total cholesterol', 'cholesterol total'],
    unit: 'mg/dL',
    minNormal: 125,
    maxNormal: 200,
    maxPlausible: 1000,
  ),
  _BiomarkerSpec(
    key: 'ldl',
    name: 'LDL Cholesterol',
    aliases: ['ldl cholesterol', 'ldl-c', 'ldl'],
    unit: 'mg/dL',
    minNormal: 0,
    maxNormal: 100,
    maxPlausible: 800,
  ),
  _BiomarkerSpec(
    key: 'hdl',
    name: 'HDL Cholesterol',
    aliases: ['hdl cholesterol', 'hdl-c', 'hdl'],
    unit: 'mg/dL',
    minNormal: 40,
    maxNormal: 100,
    maxPlausible: 250,
  ),
  _BiomarkerSpec(
    key: 'triglycerides',
    name: 'Triglycerides',
    aliases: ['triglycerides', 'triglyceride'],
    unit: 'mg/dL',
    minNormal: 0,
    maxNormal: 150,
    maxPlausible: 3000,
  ),
  _BiomarkerSpec(
    key: 'creatinine',
    name: 'Creatinine',
    aliases: ['serum creatinine', 'creatinine'],
    unit: 'mg/dL',
    minNormal: 0.6,
    maxNormal: 1.1,
    maxPlausible: 30,
  ),
  _BiomarkerSpec(
    key: 'egfr',
    name: 'eGFR',
    aliases: ['estimated glomerular filtration rate', 'egfr'],
    unit: 'mL/min/1.73m2',
    minNormal: 60,
    maxNormal: 150,
    maxPlausible: 250,
  ),
  _BiomarkerSpec(
    key: 'sodium',
    name: 'Sodium',
    aliases: ['serum sodium', 'sodium'],
    unit: 'mmol/L',
    minNormal: 136,
    maxNormal: 145,
    maxPlausible: 220,
  ),
  _BiomarkerSpec(
    key: 'potassium',
    name: 'Potassium',
    aliases: ['serum potassium', 'potassium'],
    unit: 'mmol/L',
    minNormal: 3.5,
    maxNormal: 5.1,
    maxPlausible: 15,
  ),
  _BiomarkerSpec(
    key: 'alt',
    name: 'ALT',
    aliases: ['alanine transaminase', 'sgpt', 'alt'],
    unit: 'U/L',
    minNormal: 7,
    maxNormal: 56,
    maxPlausible: 5000,
  ),
  _BiomarkerSpec(
    key: 'ast',
    name: 'AST',
    aliases: ['aspartate transaminase', 'sgot', 'ast'],
    unit: 'U/L',
    minNormal: 10,
    maxNormal: 40,
    maxPlausible: 5000,
  ),
  _BiomarkerSpec(
    key: 'tsh',
    name: 'TSH',
    aliases: ['thyroid stimulating hormone', 'tsh'],
    unit: 'mIU/L',
    minNormal: 0.4,
    maxNormal: 4,
    maxPlausible: 200,
  ),
  _BiomarkerSpec(
    key: 'vitamin_d',
    name: 'Vitamin D',
    aliases: ['25-hydroxy vitamin d', 'vitamin d3', 'vitamin d'],
    unit: 'ng/mL',
    minNormal: 30,
    maxNormal: 100,
    maxPlausible: 300,
  ),
  _BiomarkerSpec(
    key: 'vitamin_b12',
    name: 'Vitamin B12',
    aliases: ['vitamin b12', 'cobalamin'],
    unit: 'pg/mL',
    minNormal: 200,
    maxNormal: 900,
    maxPlausible: 5000,
  ),
];
