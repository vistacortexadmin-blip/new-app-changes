import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../providers/recovery_diet_provider.dart';

class ProcedureSuggestion {
  final String code;
  final String name;

  const ProcedureSuggestion({
    required this.code,
    required this.name,
  });
}

class ProcedureSearchService {
  static const String _endpoint =
      'https://clinicaltables.nlm.nih.gov/api/procedures/v3/search';

  Future<List<ProcedureSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'terms': trimmed,
        'sf': 'consumer_name,primary_name,word_synonyms,synonyms',
        'df': 'consumer_name,primary_name',
        'cf': 'key_id',
        'maxList': '15',
      },
    );

    final response = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Procedure search failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.length < 4) return const [];

    // Clinical Tables response:
    // [totalCount, codes, extraFields, displayRows, ...]
    // The previous code incorrectly read decoded[1] (codes), so the UI
    // received IDs instead of procedure names.
    final codes = decoded[1];
    final displayRows = decoded[3];

    if (displayRows is! List) return const [];

    final results = <ProcedureSuggestion>[];

    for (var i = 0; i < displayRows.length; i++) {
      final row = displayRows[i];
      if (row is! List || row.isEmpty) continue;

      String? name;
      for (final item in row) {
        if (item is String && item.trim().isNotEmpty) {
          name = item.trim();
          break;
        }
      }

      if (name == null) continue;

      String code = '';
      if (codes is List && i < codes.length) {
        code = codes[i]?.toString() ?? '';
      }

      results.add(
        ProcedureSuggestion(
          code: code,
          name: name,
        ),
      );
    }

    return results;
  }
}


class RecoveryCareScreen extends ConsumerStatefulWidget {
  const RecoveryCareScreen({super.key});

  @override
  ConsumerState<RecoveryCareScreen> createState() => _RecoveryCareScreenState();
}

class _RecoveryCareScreenState extends ConsumerState<RecoveryCareScreen> {
  final TextEditingController _procedureController = TextEditingController();
  final ProcedureSearchService _procedureSearchService = ProcedureSearchService();

  Timer? _searchDebounce;
  List<ProcedureSuggestion> _suggestions = const [];
  bool _isSearchingProcedures = false;
  String? _selectedProcedure;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _procedureController.dispose();
    super.dispose();
  }

  void _onProcedureChanged(String value) {
    _searchDebounce?.cancel();

    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _isSearchingProcedures = false;
      });
      return;
    }

    setState(() {
      _isSearchingProcedures = true;
      _selectedProcedure = null;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await _procedureSearchService.search(query);
        if (!mounted) return;

        setState(() {
          _suggestions = results;
          _isSearchingProcedures = false;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          _suggestions = const [];
          _isSearchingProcedures = false;
        });
      }
    });
  }

  void _addCustomProcedure() {
    final procedureName = _procedureController.text.trim();
    if (procedureName.isEmpty) return;

    setState(() {
      _selectedProcedure = procedureName;
      _suggestions = const [];
    });

    ref.read(recoveryDietProvider.notifier).setProcedureName(procedureName);
  }

  void _removeProcedure() {
    _searchDebounce?.cancel();
    _procedureController.clear();

    setState(() {
      _selectedProcedure = null;
      _suggestions = const [];
      _isSearchingProcedures = false;
    });

    ref.read(recoveryDietProvider.notifier).setProcedureName('');
  }

  void _selectProcedure(ProcedureSuggestion suggestion) {
    setState(() {
      _selectedProcedure = suggestion.name;
      _procedureController.text = suggestion.name;
      _procedureController.selection = TextSelection.collapsed(
        offset: _procedureController.text.length,
      );
      _suggestions = const [];
    });

    // Keep the selected procedure in the recovery plan.
    ref.read(recoveryDietProvider.notifier).setProcedureName(suggestion.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Surgery Care',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Guidance. Recovery. Better outcomes.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Procedure input with live autocomplete.
            const Text(
              'Add Procedure',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            if (_selectedProcedure != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedProcedure!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _removeProcedure,
                      tooltip: 'Remove procedure',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 21,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              )
            else
              TextField(
                controller: _procedureController,
                onChanged: _onProcedureChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Type surgery or procedure name...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _isSearchingProcedures
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_procedureController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _procedureController.clear();
                                setState(() {
                                  _suggestions = const [];
                                });
                              },
                            )
                          : null),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

            if (_selectedProcedure == null && _suggestions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];

                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.local_hospital_outlined,
                        color: AppColors.primary,
                        size: 21,
                      ),
                      title: Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => _selectProcedure(suggestion),
                    );
                  },
                ),
              ),
            ],

            if (_selectedProcedure == null &&
                !_isSearchingProcedures &&
                _procedureController.text.trim().length >= 2 &&
                _suggestions.isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No matching procedure found.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addCustomProcedure,
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Text(
              'Your Recovery Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Stepper Items matching Screen 8
            _buildRecoveryStep(
              stepNumber: '1',
              title: 'Pre-Surgery',
              subtitle: 'What to prepare, tests, and tips',
              isCurrent: false,
            ),
            _buildRecoveryStep(
              stepNumber: '2',
              title: 'Hospital Stay',
              subtitle: 'What to expect',
              isCurrent: false,
            ),
            _buildRecoveryStep(
              stepNumber: '3',
              title: 'Post-Surgery Care',
              subtitle: 'Recovery timeline and precautions',
              isCurrent: true,
            ),
            _buildRecoveryStep(
              stepNumber: '4',
              title: 'Follow-up Reminders',
              subtitle: 'Keep track of your recovery',
              isCurrent: false,
              isLast: true,
            ),
            const SizedBox(height: 18),

            // 4. Bottom Support Card matching Screen 8
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "You're not alone.\nWe're with you at every step.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0369A1),
                      height: 1.3,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_liquid_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: isCurrent ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Active',
                style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
