import 'package:challenge_delivery_flutter/models/complaint.dart';

class ComplaintDetailScreenArgs {
  final Complaint complaint;

  ComplaintDetailScreenArgs({
    required this.complaint,
  });

  ComplaintDetailScreenArgs copyWith({
    Complaint? complaint,
  }) {
    return ComplaintDetailScreenArgs(
      complaint: complaint ?? this.complaint,
    );
  }
}
