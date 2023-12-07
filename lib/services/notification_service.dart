import 'package:challenge_delivery_flutter/main.dart';
import 'package:challenge_delivery_flutter/views/courier/home_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationService {
  // Instance de Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Instance de notifications locales (pour afficher les notifications alors que l'app est en premier plan)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialisation de Firebase Messaging et des notifications locales
  Future<void> init() async {
    // Demande de permission (important pour les appareils iOS)
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
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Écoute des notifications entrantes
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received!');
      _handleMessage(message);
    });

    // Écoute lorsque l'app est en background mais pas terminée (user clicks on notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // _handleMessage(message);
      // Action personnalisée lors du clic sur la notification
      print('Message clicked!');
      print(message.data);
      if (message.data.containsKey('click_action')) {
        String clickAction = message.data['click_action'];
        switch (clickAction) {
          case 'OPEN_DELIVERY_DETAILS':
            // navigatorKey.currentState?.pushNamed('/page1', arguments: message.data['deliveryId']);
            navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const CourierProfileScreen()));
            break;
          // Add more cases as needed
        }
        // Logique pour naviguer vers 'targetPage'
        // Exemple : Navigator.pushNamed(context, targetPage);
      }
    });
  }

  // Gérer la réception des notifications
  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Message title: ${message.notification!.title}');
      _showNotification(message.notification!);
    }
  }

  // Affichage des notifications alors que l'app est en premier plan
  Future<void> _showNotification(RemoteNotification notification) async {
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

    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notification
      notification.title,
      notification.body,
      generalNotificationDetails,
    );
  }

  // Obtenir le token FCM
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  void initFCMTokenListener() {
    _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  Future<void> _sendTokenToServer(String token) async {
    // Envoyer le token à votre serveur backend
    // Utilisez votre méthode HTTP préférée pour envoyer le token
    // Par exemple, une requête POST à votre serveur Express
    try {
      await http.post(Uri.parse('${dotenv.env['API_URL']}/users'), body: {
        'token': token,
      });
      print("Token sent to server: $token");
    } catch (e) {
      print("Error sending token to server: $e");
    }
  }
}
