import 'package:challenge_delivery_flutter/bloc/payment/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/message_type_enum.dart';
import '../../helpers/loading_state.dart';
import '../../helpers/show_snack_message.dart';

class PaymentListener extends StatefulWidget {
  const PaymentListener({super.key});

  @override
  State<PaymentListener> createState() => _PaymentListenerState();
}

class _PaymentListenerState extends State<PaymentListener> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(listener: (context, state) async {
      if (state is PaymentLoadingState) {
        modalLoading(context);
      } else if (state is PaymentSuccessState) {
        print('lol');
        Navigator.of(context, rootNavigator: true).pop();
        showSnackMessage(context, 'Payment success', MessageTypeEnum.success);
      } else if (state is PaymentFailureState) {
        Navigator.of(context, rootNavigator: true).pop();
        showSnackMessage(context, state.error, MessageTypeEnum.error);
      }
    });
  }
}
