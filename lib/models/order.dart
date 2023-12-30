class Order {
  final String pickupAddress;
  final String dropoffAddress;

  const Order({
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      // id: json["id"] ?? 0,
      pickupAddress: json["pickupAddress"] ?? '',
      dropoffAddress: json["dropoffAddress"] ?? ''
  );
}
