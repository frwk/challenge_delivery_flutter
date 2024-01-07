class OrderTotal {
  final String vehicle;
  final String urgency;
  final double? total;

  const OrderTotal({
    required this.vehicle,
    required this.urgency,
    this.total,
  });

  factory OrderTotal.fromJson(Map<String, dynamic> json) => OrderTotal(
      vehicle: json["vehicle"] ?? '',
      urgency: json["dropoffAddress"] ?? '',
      total: json["total"] ?? '');
}
