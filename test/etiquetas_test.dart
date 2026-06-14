import 'package:flutter_test/flutter_test.dart';
import 'package:retag/utils/validadores.dart';

void main() {

  test('Normaliza ID removendo espaços e letras maiusculas', () {
    expect(
      normalizarEtiquetaId(' LCD 01 '),
      'lcd01',
    );
  });

  test('Etiqueta online pode enviar para LCD', () {
    expect(
      podeEnviarParaLCD(true),
      true,
    );
  });

  test('Etiqueta offline nao pode enviar para LCD', () {
    expect(
      podeEnviarParaLCD(false),
      false,
    );
  });

  test('Mensagem MQTT de display é criada corretamente', () {
    final msg = criarMensagemDisplay(
      id: 'label01',
      nome: 'Arroz',
      preco: 10.5,
    );

    expect(msg['action'], 'display');
    expect(msg['id'], 'label01');
    expect(msg['nome'], 'Arroz');
    expect(msg['preco'], 10.5);
  });
}