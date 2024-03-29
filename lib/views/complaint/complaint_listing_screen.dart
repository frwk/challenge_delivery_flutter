import 'dart:convert';
import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:challenge_delivery_flutter/widgets/error.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
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
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;
    List<Complaint> fetchedComplaints = await complaintService.get(authUser!.id);
    return fetchedComplaints;
  }

  callback(updatedComplaint) {
    complaints.then((complaints) => setState(() {
          complaints[complaints.indexWhere((complaint) => complaint.id == updatedComplaint.id)] = updatedComplaint;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: 'Réclamations',
          hasBackArrow: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async => refreshComplaints(context),
          child: FutureBuilder<List<Complaint>>(
            future: complaints,
            builder: (context, AsyncSnapshot<List<Complaint>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Complaint> fetchedComplaints = snapshot.data!;
                if (fetchedComplaints.isEmpty) {
                  return ErrorMessage(
                    icon: Icons.search_off,
                    message: 'Aucune réclamation en cours',
                    actions: [
                      ButtonAtom(
                          data: 'Commandes', color: Theme.of(context).colorScheme.primary, onTap: () => Navigator.of(context).pushNamed('/history')),
                    ],
                  );
                }
                fetchedComplaints.sort((a, b) => a.status!.compareTo(b.status!));

                return RefreshIndicator(
                  onRefresh: () => refreshComplaints(context),
                  child: ListView.builder(
                    itemCount: fetchedComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = fetchedComplaints[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/complaint-detail',
                              arguments: ComplaintDetailScreenArgs(complaint: complaint, callback: callback));
                        },
                        child: MyCard(
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
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: complaint.status == 'resolved' ? Colors.green : Colors.orange,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            complaint.status == 'resolved' ? 'Résolu' : 'En cours',
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
                                      complaint.delivery?.courier != null
                                          ? 'Livreur : ${complaint.delivery?.courier?.user?.firstName} ${complaint.delivery?.courier?.user?.lastName}'
                                          : 'Aucun livreur affecté',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Créé le : ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.parse(complaint.createdAt!))}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ));
  }
}
