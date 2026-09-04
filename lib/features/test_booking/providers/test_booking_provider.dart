import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_booking_model.dart';
import '../../../core/storage/seed_data.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../reminders/models/reminder_model.dart';

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
      final matchesCat = selectedCategory == null || t.category == selectedCategory;
      final matchesQuery = searchQuery.isEmpty ||
          t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.includedParameters.any((p) => p.toLowerCase().contains(searchQuery.toLowerCase()));
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
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
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
          confirmedOrders: [],
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

  void selectTestAndProvider({BookableTest? test, DiagnosticProvider? provider}) {
    state = state.copyWith(
      selectedTest: test ?? state.selectedTest,
      selectedProvider: provider ?? state.selectedProvider,
    );
  }

  TestBookingOrder confirmBooking({
    required BookableTest test,
    required DiagnosticProvider provider,
    required DateTime date,
    required String timeSlot,
    required bool isHomeCollection,
  }) {
    final order = TestBookingOrder(
      orderId: 'ORD_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
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

    // Automatically sync booking to Next-Test Reminder Engine! (PRD 3.9 requirement)
    ref.read(remindersProvider.notifier).addNextTestReminder(
          NextTestReminder(
            id: 'book_${order.orderId}',
            testName: test.name,
            labOrClinicName: provider.name,
            scheduledDate: date,
            preparationInstructions: test.preparationInstruction,
          ),
        );

    return order;
  }
}

final testBookingProvider =
    StateNotifierProvider<TestBookingNotifier, TestBookingState>((ref) {
  return TestBookingNotifier(ref);
});
