import 'dart:convert';

import 'package:challenge_delivery_flutter/main.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload == null) {
    return;
  }
  Map<String, dynamic> payload = jsonDecode(notificationResponse.payload!);
  if (payload.containsKey('click_action')) {
    switch (payload['click_action']) {
      case 'OPEN_DELIVERY_DETAILS':
        navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => const CourierLayout(initialIndex: 1)));
        break;
    }
  }
}

class NotificationService {
  // Instance de Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Instance de notifications locales (pour afficher les notifications alors que l'app est en premier plan)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Configuration pour les notifications locales
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Écoute des notifications entrantes
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Écoute lorsque l'app est en background mais pas terminée (user clicks on notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('click_action')) {
        String clickAction = message.data['click_action'];
        switch (clickAction) {
          case 'OPEN_DELIVERY_DETAILS':
            navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => const CourierLayout(initialIndex: 1)));
            break;
        }
      }
    });
  }

  // Gérer la réception des notifications
  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showNotification(message.notification!, message.data);
    }
  }

  // Affichage des notifications alors que l'app est en premier plan
  Future<void> _showNotification(RemoteNotification notification, Map<String, dynamic> data) async {
    var androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.max,
    );
    var generalNotificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, generalNotificationDetails, payload: jsonEncode(data));
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
