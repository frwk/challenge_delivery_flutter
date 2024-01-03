import 'package:challenge_delivery_flutter/components/complaint_chat.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/state/app_state.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:flutter/material.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Function? callback;

  const ComplaintDetailScreen({super.key, this.callback});

  @override
  ComplaintDetailScreenState createState() => ComplaintDetailScreenState();
}

class ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as ComplaintDetailScreenArgs?;
      AppState.currentPageKey = 'complaint-detail-${args!.complaint.id}';
    });
  }

  @override
  void dispose() {
    AppState.currentPageKey = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ComplaintDetailScreenArgs?;
    Complaint complaint = args!.complaint;

    return Scaffold(
      appBar: AppBar(
        title: Text('Réclamation #${complaint.id}'),
        actions: [
          if (complaint.status == 'pending')
            PopupMenuButton(
                itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'close',
                        child: Text('Fermer la réclamation'),
                      ),
                    ],
                onSelected: (value) async {
                  if (value == 'close') {
                    await complaintService.markAsResolved(complaint.id!);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                })
          else
            const SizedBox(),
        ],
      ),
      body: ChatWidget(
        complaint: complaint,
      ),
    );
  }
}
