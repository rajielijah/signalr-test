import 'dart:developer';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:signalr_core/signalr_core.dart';

import 'Models/message.dart';

class SignalRHelper {
  final url = 'https://onecareinnovastrachat.azurewebsites.net/chathub';
  HubConnection? hubConnection;
  var messageList = <Message>[];
  String textMessage = '';
  int? toUserId;
  Future<void> connect(receiveMessageHandler, int? fromUserIds) async {
    try {
      hubConnection = HubConnectionBuilder()
          .withAutomaticReconnect(1000)
          .withUrl(url, HttpConnectionOptions(
        client: IOClient(HttpClient()..badCertificateCallback = (x, y, z) => true),
        logging: (level, message) => print(message),))
          .build();
      hubConnection?.onclose((error) {
        log('Connection Close');
      });
      int fromUserId = 30358;
      hubConnection?.on('ReceiveMessage', ([textMessage, fromUserId]) => {
          if(fromUserIds == toUserId) {
          messageList.add(Message(
            message: textMessage.toString(),
            isMine: false))
          }
      });
      log("we gottan test $receiveMessageHandler");
      await _start();
    } catch (e) {
      log("SignalR " + e.toString());
    }
  }

  void sendMessage(String message, int fromUserId,) {
    hubConnection?.invoke('SendMessage', args: [message, fromUserId, 30358]);
    messageList.add(Message(
        message: message,
        isMine: true));
    log(fromUserId.toString());
    textMessage = '';
  }

  Future<void> _start() async {
    await hubConnection?.start();
    log(hubConnection?.connectionId ?? "");
  }

  bool isWorking() {
    return hubConnection?.state?.index == 2;
  }

  Future<void> disconnect() async {
    hubConnection?.stop();
  }

  Future<void> reStart() async {
    await hubConnection?.stop();
    await _start();
    // await SignalRSend().identify();
  }

  Future<bool> restartIfNeedIt() async {
    if (!isWorking()) {
      await reStart();
    } else {
      // await SignalRSend().identify();
    }
    return isWorking();
  }
}
