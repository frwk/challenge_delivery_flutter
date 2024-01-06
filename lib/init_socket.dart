import 'dart:async';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class InitSocket {
  static InitSocket? _instance;
  late WebSocketChannel _webSocketChannel;
  late StreamController<String> _streamController;

  InitSocket._();

  static InitSocket getInstance() {
    _instance ??= InitSocket._();
    return _instance!;
  }

  WebSocketChannel get webSocketChannel {
    if (_webSocketChannel == null) {
      throw Exception('WebSocketChannel not initialized. Call init() first.');
    }
    return _webSocketChannel;
  }

  Stream<String> get stream => _streamController.stream;

  Future<WebSocketChannel> init() async {
    final cookie = await secureStorage.readCookie();
    final token = cookie.toString().split(';')[0].split('=')[1];
    _webSocketChannel = WebSocketChannel.connect(
      Uri.parse(
        '${dotenv.env['API_URL']!.replaceAll('http', 'ws')}/ws?token=$token',
      ),
    );

    _streamController = StreamController<String>.broadcast();

    _webSocketChannel.stream.listen(
      (data) {
        _streamController.add(data);
      },
      onDone: () {
        _streamController.close();
      },
      onError: (error) {
        _streamController.addError(error);
      },
    );

    await _webSocketChannel.ready;
    return _webSocketChannel;
  }
}
