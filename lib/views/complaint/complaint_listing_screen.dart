import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ComplaintListingScreen extends StatefulWidget {
  const ComplaintListingScreen({super.key});

  @override
  State<ComplaintListingScreen> createState() => _ComplaintListingScreenState();
}

class _ComplaintListingScreenState extends State<ComplaintListingScreen> {
  late Future<List<Complaint>> complaints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      complaints = getComplaints(context);
    });
  }

  Future<void> refreshComplaints(BuildContext context) async {
    setState(() {
      complaints = getComplaints(context);
    });
  }

  Future<List<Complaint>> getComplaints(BuildContext context) async {
    final authUser = BlocProvider.of<UserBloc>(context).state.user;
    List<Complaint> fetchedComplaints =
        await complaintService.get(authUser!.id);
    return fetchedComplaints;
  }

  callback(updatedComplaint) {
    complaints.then((complaints) => setState(() {
          complaints[complaints.indexWhere(
                  (complaint) => complaint.id == updatedComplaint.id)] =
              updatedComplaint;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Réclamations',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: FutureBuilder<List<Complaint>>(
          future: complaints,
          builder: (context, AsyncSnapshot<List<Complaint>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Complaint> fetchedComplaints = snapshot.data!;
              fetchedComplaints.sort((a, b) => a.status.compareTo(b.status));

              return RefreshIndicator(
                onRefresh: () => refreshComplaints(context),
                child: ListView.builder(
                  itemCount: fetchedComplaints.length,
                  itemBuilder: (context, index) {
                    final complaint = fetchedComplaints[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/complaint-detail',
                            arguments: ComplaintDetailScreenArgs(
                                complaint: complaint, callback: callback));
                      },
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Réclamation',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: ' #${complaint.id}',
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color:
                                                complaint.status == 'resolved'
                                                    ? Colors.green
                                                    : Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            complaint.status == 'resolved'
                                                ? 'Résolu'
                                                : 'En cours',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Informations sur la livraison :',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Livreur : ${complaint.delivery.courier.user.firstName} ${complaint.delivery.courier.user.lastName}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Créé le : ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.parse(complaint.createdAt))}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}
