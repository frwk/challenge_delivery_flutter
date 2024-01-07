import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:flutter/material.dart';

class ComplaintDetailScreenArgs {
  final Complaint complaint;
  final Function? callback;
  final List<Widget>? actionsButtons;

  ComplaintDetailScreenArgs({
    required this.complaint,
    this.callback,
    this.actionsButtons,
  });

  ComplaintDetailScreenArgs copyWith({
    Complaint? complaint,
    Function(Complaint)? callback,
    List<Widget>? actionsButtons,
  }) {
    return ComplaintDetailScreenArgs(
      complaint: complaint ?? this.complaint,
      callback: callback ?? this.callback,
      actionsButtons: actionsButtons ?? this.actionsButtons,
    );
  }
}
