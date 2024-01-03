import 'package:challenge_delivery_flutter/interfaces/user_stats.dart';

class ClientStats extends UserStats {
  ClientStats({
    int? totalDeliveries,
    double? totalDistance,
    double? averageRating,
    double? totalDuration,
  }) : super(
          totalDeliveries: totalDeliveries,
          totalDistance: totalDistance,
          averageRating: averageRating,
          totalDuration: totalDuration,
        );

  factory ClientStats.fromJson(Map<String, dynamic> json) {
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

    return ClientStats(
      totalDeliveries: tryParseInt(json['totalDeliveries']),
      totalDistance: tryParseDouble(json['totalDistance']),
      averageRating: tryParseDouble(json['averageRating']),
      totalDuration: tryParseDouble(json['totalDuration']),
    );
  }
}
