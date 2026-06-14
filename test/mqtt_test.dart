import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mensagem display montada corretamente', () {
    final mensagem = {
      "action": "display",
      "id": "abc123",
      "nome": "Arroz",
      "preco": 10.5,
    };

    final json = jsonEncode(mensagem);

    expect(json, contains('"action":"display"'));
    expect(json, contains('"id":"abc123"'));
    expect(json, contains('"nome":"Arroz"'));
  });

  test('Mensagem update montada corretamente', () {
    final mensagem = {
      "action": "update",
      "id": "abc123",
      "nome": "Feijão",
      "preco": 12.0,
      "online": true,
    };

    final json = jsonEncode(mensagem);

    expect(json, contains('"action":"update"'));
    expect(json, contains('"online":true'));
  });

  test('Mensagem delete montada corretamente', () {
    final mensagem = {
      "action": "delete",
      "id": "abc123",
    };

    final json = jsonEncode(mensagem);

    expect(json, contains('"action":"delete"'));
    expect(json, contains('"id":"abc123"'));
  });

  test('Mensagem connect interpretada corretamente', () {
    const payload = '{"action":"connect","id":"lcd01"}';

    final data = jsonDecode(payload);

    expect(data["action"], "connect");
    expect(data["id"], "lcd01");
  });

  test('Mensagem disconnect interpretada corretamente', () {
    const payload = '{"action":"disconnect","id":"lcd01"}';

    final data = jsonDecode(payload);

    expect(data["action"], "disconnect");
    expect(data["id"], "lcd01");
  });
}