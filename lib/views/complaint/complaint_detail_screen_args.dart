import 'package:challenge_delivery_flutter/models/complaint.dart';

class ComplaintDetailScreenArgs {
  final Complaint complaint;
  final Function callback;

  ComplaintDetailScreenArgs({
    required this.complaint,
    required this.callback,
  });

  ComplaintDetailScreenArgs copyWith({
    Complaint? complaint,
    Function(Complaint)? callback,
  }) {
    return ComplaintDetailScreenArgs(
      complaint: complaint ?? this.complaint,
      callback: callback ?? this.callback,
    );
  }
}
