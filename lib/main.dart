import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/order/order_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/init_socket.dart';
import 'package:challenge_delivery_flutter/listener/checking_login_listener.dart';
import 'package:challenge_delivery_flutter/themes/light_mode.dart';
import 'package:challenge_delivery_flutter/views/auth/forgot_password_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/register/register_screen.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_listing_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/change_password_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/deliveries_history_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/map_delivery_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/edit_profile_screen.dart';
import 'package:challenge_delivery_flutter/views/home_screen.dart';
import 'package:challenge_delivery_flutter/views/order/create_order_screen.dart';
import 'package:challenge_delivery_flutter/views/order/order_summary.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/views/order/create_order_screen.dart';
import 'package:challenge_delivery_flutter/views/payment/payment_success_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:challenge_delivery_flutter/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

NotificationService notificationService = NotificationService();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51OUxtlAnhXlPAgUCByMDs22yNMcqgIVOzxc6cFhCIraj277uVjwebcFBEARWtgeBE5qmm2wbq6Q8YovVR5t9lUGi00GifYfd48";
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  notificationService.init();
  String? token = await notificationService.getToken();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(CheckLoginEvent())),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => OrderBloc()),
        BlocProvider(create: (context) => DeliveryTrackingBloc()),
      ],
      child: MaterialApp(
          theme: lightMode(),
          navigatorKey: navigatorKey,
          supportedLocales: const [
            Locale('fr'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FormBuilderLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Challenge Delivery',
          home: const CheckingLoginListener(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterClientScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/create-order': (context) => const CreateOrderScreen(),
            '/order-summary': (context) => const OrderSummaryScreen(),
            '/payment-success': (context) => const PaymentSuccessScreen(),
            '/complaints': (context) => const ComplaintListingScreen(),
            '/complaint-detail': (context) => const ComplaintDetailScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/history': (context) => const DeliveriesHistoryScreen(),
            '/delivery-tracking': (context) => const MapDeliveryScreen(),
          }),
    );
  }
}
