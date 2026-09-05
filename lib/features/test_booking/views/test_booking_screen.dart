import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../providers/test_booking_provider.dart';
import '../models/test_booking_model.dart';

class TestBookingScreen extends ConsumerWidget {
  const TestBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testBookingProvider);
    final tests = state.filteredTests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Diagnostic Test Booking'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(testBookingProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search tests (e.g. Lipid, Thyroid, HbA1c)...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          Container(
            color: AppColors.background,
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'All Tests',
                  isSelected: state.selectedCategory == null,
                  onSelected: () =>
                      ref.read(testBookingProvider.notifier).selectCategory(null),
                ),
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'Blood & Metabolic',
                  isSelected: state.selectedCategory == 'Blood & Metabolic',
                  onSelected: () => ref
                      .read(testBookingProvider.notifier)
                      .selectCategory('Blood & Metabolic'),
                ),
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'Diabetic Health',
                  isSelected: state.selectedCategory == 'Diabetic Health',
                  onSelected: () => ref
                      .read(testBookingProvider.notifier)
                      .selectCategory('Diabetic Health'),
                ),
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'Endocrinology',
                  isSelected: state.selectedCategory == 'Endocrinology',
                  onSelected: () => ref
                      .read(testBookingProvider.notifier)
                      .selectCategory('Endocrinology'),
                ),
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'Vital Vitamins',
                  isSelected: state.selectedCategory == 'Vital Vitamins',
                  onSelected: () => ref
                      .read(testBookingProvider.notifier)
                      .selectCategory('Vital Vitamins'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          Expanded(
            child: tests.isEmpty
                ? const Center(
                    child: Text(
                      'No diagnostic tests matching query.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      return _buildTestCard(context, ref, test, state.providers);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primarySurface,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, WidgetRef ref, BookableTest test,
      List<DiagnosticProvider> providers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  test.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Text(
                '₹${test.price.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            test.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            test.description,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${test.includedParameters.length} Parameters included',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  _showSelectProviderAndSlotModal(context, ref, test, providers);
                },
                child: const Text('Book Test Slot'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSelectProviderAndSlotModal(
    BuildContext context,
    WidgetRef ref,
    BookableTest test,
    List<DiagnosticProvider> providers,
  ) {
    DiagnosticProvider selectedProvider = providers.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    String selectedSlot = '08:00 AM - 09:00 AM';
    bool isHomeCollection = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book: ${test.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Price: ₹${test.price.toInt()} (Includes digital report delivery)',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  const Text('Select Participating Lab Provider:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<DiagnosticProvider>(
                    value: selectedProvider,
                    dropdownColor: AppColors.surface,
                    isExpanded: true,
                    items: providers.map((prov) {
                      return DropdownMenuItem(
                        value: prov,
                        child: Text(
                          '${prov.name} (${prov.distanceKm} km · ⭐ ${prov.rating})',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedProvider = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Preferred Time Slot:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedSlot,
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: '07:30 AM - 08:30 AM (Fasting Slot)', child: Text('07:30 AM - 08:30 AM (Fasting)')),
                      DropdownMenuItem(value: '08:00 AM - 09:00 AM', child: Text('08:00 AM - 09:00 AM')),
                      DropdownMenuItem(value: '09:00 AM - 10:00 AM', child: Text('09:00 AM - 10:00 AM')),
                      DropdownMenuItem(value: '10:30 AM - 11:30 AM', child: Text('10:30 AM - 11:30 AM')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedSlot = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.primary,
                    title: const Text('Free Home Sample Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: const Text('Phlebotomist visits home at designated slot', style: TextStyle(fontSize: 11)),
                    value: isHomeCollection,
                    onChanged: (val) {
                      setModalState(() => isHomeCollection = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final order = ref.read(testBookingProvider.notifier).confirmBooking(
                              test: test,
                              provider: selectedProvider,
                              date: selectedDate,
                              timeSlot: selectedSlot,
                              isHomeCollection: isHomeCollection,
                            );

                        _showBookingSuccessDialog(context, order);
                      },
                      child: const Text('Confirm & Schedule Slot'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingSuccessDialog(BuildContext context, TestBookingOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              SizedBox(width: 8),
              Text('Booking Confirmed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Text('Test: ${order.test.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('Provider: ${order.provider.name}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('Date & Slot: ${DateFormat('dd MMM yyyy').format(order.scheduledDate)} at ${order.timeSlot}', style: const TextStyle(fontSize: 12)),
              const Divider(height: 20, color: AppColors.divider),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.alarm_on_rounded, size: 16, color: AppColors.info),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Automatically added to your Next-Test Reminder engine!',
                        style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
