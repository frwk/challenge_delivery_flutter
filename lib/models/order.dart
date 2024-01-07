class Order {
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicle;
  final String urgency;
  final int? total;
  final int? distance;
  final int? duration;

  const Order({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicle,
    required this.urgency,
    this.total,
    this.distance,
    this.duration,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      pickupAddress: json["pickupAddress"] ?? '',
      dropoffAddress: json["dropoffAddress"] ?? '',
      vehicle: json["vehicle"] ?? '',
      urgency: json["urgency"] ?? '',
      total: (json["total"] is String ? double.parse(json["total"]) : json["total"] ?? 0).toInt(),
      distance: json["distance"] ?? 0,
      duration: json["duration"] ?? 0);
}
