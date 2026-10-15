import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/seed_data.dart';
import '../../reminders/models/reminder.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../models/test_booking_model.dart';

class TestBookingState {
  final List<DiagnosticProvider> providers;
  final List<BookableTest> tests;
  final List<TestBookingOrder> confirmedOrders;
  final String searchQuery;
  final String? selectedCategory;
  final BookableTest? selectedTest;
  final DiagnosticProvider? selectedProvider;

  TestBookingState({
    required this.providers,
    required this.tests,
    required this.confirmedOrders,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedTest,
    this.selectedProvider,
  });

  List<BookableTest> get filteredTests {
    return tests.where((t) {
      final matchesCat =
          selectedCategory == null || t.category == selectedCategory;
      final matchesQuery = searchQuery.isEmpty ||
          t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.includedParameters
              .any((p) => p.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesCat && matchesQuery;
    }).toList();
  }

  TestBookingState copyWith({
    List<DiagnosticProvider>? providers,
    List<BookableTest>? tests,
    List<TestBookingOrder>? confirmedOrders,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    BookableTest? selectedTest,
    DiagnosticProvider? selectedProvider,
  }) {
    return TestBookingState(
      providers: providers ?? this.providers,
      tests: tests ?? this.tests,
      confirmedOrders: confirmedOrders ?? this.confirmedOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedTest: selectedTest ?? this.selectedTest,
      selectedProvider: selectedProvider ?? this.selectedProvider,
    );
  }
}

class TestBookingNotifier extends StateNotifier<TestBookingState> {
  final Ref ref;

  TestBookingNotifier(this.ref)
      : super(TestBookingState(
          providers: SeedData.diagnosticProviders,
          tests: SeedData.bookableTests,
          confirmedOrders: const [],
        ));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void selectTestAndProvider({
    BookableTest? test,
    DiagnosticProvider? provider,
  }) {
    state = state.copyWith(
      selectedTest: test ?? state.selectedTest,
      selectedProvider: provider ?? state.selectedProvider,
    );
  }

  Future<TestBookingOrder> confirmBooking({
    required BookableTest test,
    required DiagnosticProvider provider,
    required DateTime date,
    required String timeSlot,
    required bool isHomeCollection,
  }) async {
    final order = TestBookingOrder(
      orderId:
          'ORD_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      test: test,
      provider: provider,
      scheduledDate: date,
      timeSlot: timeSlot,
      isHomeCollection: isHomeCollection,
      bookingStatus: 'Confirmed',
      amountPaid: test.price,
    );

    state = state.copyWith(
      confirmedOrders: [order, ...state.confirmedOrders],
    );

    // Auto-create a reminder for the booked test using the actual
    // date + time slot so it appears in the Reminders "Tests" tab.
    final scheduledDateTime = _parseSlotToDateTime(date, timeSlot);

    await ref.read(reminderRepositoryProvider).addReminder(
          title: 'Lab test: ${test.name}',
          type: ReminderType.TEST,
          scheduledTime: scheduledDateTime,
          source: ReminderSource.auto,
          relatedTestId: order.orderId,
        );

    // Reset the Reminders filter so the auto-created test reminder
    // is visible the moment the user opens the Reminders tab.
    ref.read(reminderFilterProvider.notifier).state = null;

    return order;
  }

  /// Converts "10:30 AM - 11:00 AM" + date -> DateTime(date, 10, 30)
  DateTime _parseSlotToDateTime(DateTime date, String slot) {
    final startPart = slot.split('-').first.trim();
    final regex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(startPart);

    if (match == null) {
      // Fallback: 9:00 AM on the chosen date
      return DateTime(date.year, date.month, date.day, 9, 0);
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!.toUpperCase();

    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

final testBookingProvider =
    StateNotifierProvider<TestBookingNotifier, TestBookingState>((ref) {
  return TestBookingNotifier(ref);
});
