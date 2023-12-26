import 'dart:convert';

import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/init_socket.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/models/complaint_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum UserType {
  client("client"),
  courier("courier"),
  support("support"),
  admin("admin");

  const UserType(this.value);
  final String value;
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, required this.complaint});

  final Complaint complaint;

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  List<MessageData> _messageHistory = [];
  final WebSocketChannel webSocketChannel = InitSocket.getInstance().webSocketChannel;

  @override
  void initState() {
    super.initState();
    _joinChat();
  }

  void _joinChat() async {
    webSocketChannel.sink.add(json.encode({
      "type": "join",
      "data": {"complaintId": widget.complaint.id}
    }));
  }

  void _sendMessage(int userId) {
    if (widget.complaint.status == 'resolved') return;
    final message = _messageController.text;
    if (message.isEmpty) return;
    webSocketChannel.sink.add(json.encode({
      "type": "chat",
      "data": {
        "userType": UserType.client.value,
        "complaintId": widget.complaint.id,
        "userId": userId,
        "content": message,
        "date": DateTime.now().toIso8601String(),
      }
    }));
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = BlocProvider.of<UserBloc>(context).state.user;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: InitSocket.getInstance().stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final response = MessageResponse.fromJson(
                    json.decode(snapshot.data.toString()),
                  );

                  if (response.type == 'join') {
                    final messages = (response.data as List).map((message) => MessageData.fromJson(message)).toList();

                    _messageHistory = messages;
                  } else if (response.type == 'chat') {
                    final message = MessageData.fromJson(response.data);
                    _messageHistory.add(message);
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: _messageHistory.length,
                    itemBuilder: (context, index) {
                      final message = _messageHistory[_messageHistory.length - 1 - index];
                      final isClient = message.userType == UserType.client || message.userType == UserType.courier;
                      final isSupport = message.userType == UserType.support || message.userType == UserType.admin;

                      return Align(
                        alignment: isClient ? Alignment.topRight : Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: isClient
                                ? Colors.blue
                                : isSupport
                                    ? Colors.green
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    message.userType.value.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${message.date.day.toString().padLeft(2, '0')}/${message.date.month.toString().padLeft(2, '0')}/${message.date.year} ${message.date.hour.toString().padLeft(2, '0')}:${message.date.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: const Color(0xFFEEEEEE).withOpacity(0.7),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                message.content,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: widget.complaint.status == 'resolved',
                      autofocus: true,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: widget.complaint.status == 'resolved' ? 'Réclamation résolue...' : 'Écrivez votre message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _sendMessage(authUser!.id),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () => _sendMessage(authUser!.id),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
