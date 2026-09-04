class DiagnosticProvider {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int totalReviews;
  final double distanceKm;
  final String accreditedBy; // e.g. "NABL & CAP Accredited"
  final bool homeCollectionAvailable;
  final String contactPhone;

  DiagnosticProvider({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.totalReviews,
    required this.distanceKm,
    required this.accreditedBy,
    this.homeCollectionAvailable = true,
    required this.contactPhone,
  });
}

class BookableTest {
  final String id;
  final String name;
  final String category; // Blood, Imaging, Cardiology, Pathology
  final String description;
  final String preparationInstruction; // e.g. "10-12 hours fasting required"
  final double price;
  final String reportDeliveryTime; // e.g. "Within 12 hours"
  final List<String> includedParameters;

  BookableTest({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.preparationInstruction,
    required this.price,
    required this.reportDeliveryTime,
    required this.includedParameters,
  });
}

class TestBookingOrder {
  final String orderId;
  final BookableTest test;
  final DiagnosticProvider provider;
  final DateTime scheduledDate;
  final String timeSlot;
  final bool isHomeCollection;
  final String bookingStatus; // "Confirmed", "Sample Collected", "Report Ready"
  final double amountPaid;

  TestBookingOrder({
    required this.orderId,
    required this.test,
    required this.provider,
    required this.scheduledDate,
    required this.timeSlot,
    required this.isHomeCollection,
    required this.bookingStatus,
    required this.amountPaid,
  });
}
