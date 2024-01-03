class UserStats {
  int? totalDeliveries;
  double? totalDistance;
  double? averageRating;
  double? totalDuration;

  UserStats({
    this.totalDeliveries,
    this.totalDistance,
    this.averageRating,
    this.totalDuration,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value is String) {
        return int.tryParse(value);
      } else if (value is int) {
        return value;
      }
      return null;
    }

    double? tryParseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value);
      } else if (value is double) {
        return value;
      }
      return null;
    }

    return UserStats(
      totalDeliveries: tryParseInt(json['totalDeliveries']),
      totalDistance: tryParseDouble(json['totalDistance']),
      averageRating: tryParseDouble(json['averageRating']),
      totalDuration: tryParseDouble(json['totalDuration']),
    );
  }
}
