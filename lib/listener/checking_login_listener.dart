import 'package:challenge_delivery_flutter/bloc/blocs.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';

class CheckingLoginListener extends StatefulWidget {
  const CheckingLoginListener({super.key});

  @override
  _CheckingLoginListenerState createState() => _CheckingLoginListenerState();
}

class _CheckingLoginListenerState extends State<CheckingLoginListener> with TickerProviderStateMixin {
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
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CheckingLoginListener()), (route) => false);
        } else if (state is LogOutAuthState || state is FailureAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        } else if (state is SuccessAuthState && state.user?.role != null) {
          userBloc.add(OnGetUserEvent(state.user!));
          print('SUCCESS AUTH STATE');
          print(state.user?.role);
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
