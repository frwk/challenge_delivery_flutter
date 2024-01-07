import 'package:challenge_delivery_flutter/components/complaint_chat.dart';

class MessageData {
  final UserType userType;
  final DateTime date;
  final String content;
  final int? complaintId;
  final int? userId;

  MessageData({
    required this.userType,
    required this.date,
    required this.content,
    this.complaintId,
    this.userId,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      userType:
          UserType.values.firstWhere((e) => e.toString().split('.').last == json['userType'], orElse: () => throw Exception('Invalid user type')),
      date: DateTime.parse(json['date']),
      content: json['content'],
      complaintId: json['complaintId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userType': userType.value,
        'date': date.toIso8601String(),
        'content': content,
        'complaintId': complaintId,
        'userId': userId,
      };
}

class MessageResponse {
  final String type;
  final dynamic data;

  MessageResponse({required this.type, required this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      type: json['type'],
      data: json['data'],
    );
  }
}
