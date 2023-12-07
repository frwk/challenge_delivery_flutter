import 'package:challenge_delivery_flutter/bloc/order/order_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/themes/light_mode.dart';
import 'package:challenge_delivery_flutter/views/auth/forgot_password_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/register/register_first_step.dart';
import 'package:challenge_delivery_flutter/views/auth/register/register_screen.dart';
import 'package:challenge_delivery_flutter/views/client/dashboard/home_screen.dart';
import 'package:challenge_delivery_flutter/views/on_boarding/splash_view.dart';
import 'package:challenge_delivery_flutter/views/order/create_order_screen.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:challenge_delivery_flutter/bloc/blocs.dart';
import 'package:challenge_delivery_flutter/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

NotificationService notificationService = NotificationService();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
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
    // notificationService.onMessagingListener();
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
      ],
      child: MaterialApp(
          theme: lightMode(),
          navigatorKey: navigatorKey, // Ajouter cette ligne
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
          home: const SplashView(),
          routes: {
            '/client/home': (context) => const ClientHomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterClientScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/create-order': (context) => const CreateOrderScreen(),
          }),
    );
  }
}
