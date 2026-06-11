import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../secrets.dart';

class MqttService {
  late MqttServerClient client;

  Future<void> connect() async {
    client = MqttServerClient(mqttHost, 'flutter_client');

    client.port = mqttPort;
    client.secure = true;
    client.logging(on: false);

    client.keepAlivePeriod = 20;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs(mqttUser, mqttPassword)
        .startClean();

    try {
      await client.connect();
      print('MQTT conectado!');

      client.subscribe(
        mqttTopic,
        MqttQos.atLeastOnce,
      );

      print("MQTT conectado!");
    } catch (e) {
      print('Erro MQTT: $e');
      client.disconnect();
    }
  }

  void sendMessage(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client.publishMessage(
      mqttTopic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  void listenMessages(Function(String message) onMessage) {
    print("Iniciando listener MQTT");

    client.updates?.listen(
          (List<MqttReceivedMessage<MqttMessage>> events) {
        final recMess =
        events[0].payload as MqttPublishMessage;

        final message =
        MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        onMessage(message);
      },
    );
  }

  void disconnect() {
    client.disconnect();
  }
}