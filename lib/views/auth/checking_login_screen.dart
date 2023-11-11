import 'package:challenge_delivery_flutter/bloc/blocs.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/views/auth/login_screen.dart';

class CheckingLoginScreen extends StatefulWidget {
  const CheckingLoginScreen({super.key});

  @override
  _CheckingLoginScreenState createState() => _CheckingLoginScreenState();
}

class _CheckingLoginScreenState extends State<CheckingLoginScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoadingAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CheckingLoginScreen()), (route) => false);
        } else if (state is LogOutAuthState || state is FailureAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        } else if (state is SuccessAuthState && state.user?.role != null) {
          userBloc.add(OnGetUserEvent(state.user!));
          if (state.user?.role == 'client') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false);
          } else if (state.user?.role == 'courier') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false);
          }
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(height: 200, width: 200, child: Image(image: AssetImage('assets/logo.png'))),
            )
          ],
        ),
      ),
    );
  }
}
