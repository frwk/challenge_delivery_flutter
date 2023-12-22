class Order {
  final String pickupAddress;
  final String dropoffAddress;
  final String packageType;
  final String packageWeight;

  const Order({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.packageType,
    required this.packageWeight,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      // id: json["id"] ?? 0,
      pickupAddress: json["pickupAddress"] ?? '',
      dropoffAddress: json["dropoffAddress"] ?? '',
      packageType: json["packageType"] ?? '',
      packageWeight: json["packageWeight"] ?? '');
}
