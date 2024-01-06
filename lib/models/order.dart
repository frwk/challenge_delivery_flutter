class Order {
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicle;
  final String urgency;
  final int? total;

  const Order({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicle,
    required this.urgency,
    this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      // id: json["id"] ?? 0,
      pickupAddress: json["pickupAddress"] ?? '',
      dropoffAddress: json["dropoffAddress"] ?? '',
      vehicle: json["vehicle"] ?? '',
      urgency: json["dropoffAddress"] ?? '',
      total: json["total"] ?? '');
}
