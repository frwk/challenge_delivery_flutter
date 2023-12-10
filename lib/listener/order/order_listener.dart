import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/order/order_bloc.dart';
import '../../enums/message_type_enum.dart';
import '../../helpers/loading_state.dart';
import '../../helpers/show_snack_message.dart';

class OrderListener extends StatefulWidget {
  const OrderListener({super.key});

  @override
  State<OrderListener> createState() => _OrderListenerState();
}

class _OrderListenerState extends State<OrderListener> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderBloc = BlocProvider.of<OrderBloc>(context);

    return BlocListener<OrderBloc, OrderState>(
        listener: (context, state) async {
          print(state);
          if (state is OrderLoadingState) {
            modalLoading(context);
          } else if (state is OrderAddressSuccessState && state.order != null) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          else if (state is OrderFailureState) {
            Navigator.of(context, rootNavigator: true).pop();
            showSnackMessage(context, state.error, MessageTypeEnum.error);
          } else if (state is OrderSuccessState) {
            Navigator.of(context, rootNavigator: true).pop();
            showSnackMessage(context, 'Order created', MessageTypeEnum.success);
          }
        },
    );
  }
}
