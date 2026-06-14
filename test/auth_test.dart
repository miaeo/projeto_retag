import 'package:flutter_test/flutter_test.dart';
import 'package:retag/utils/validadores.dart';

void main() {

  test('Senha valida retorna vazio', () {
    expect(
      validarSenhaMensagem('Senha123'),
      '',
    );
  });

  test('Senha curta retorna erro', () {
    expect(
      validarSenhaMensagem('Ab1'),
      contains('mín. 6 caracteres'),
    );
  });

  test('Senha sem maiuscula retorna erro', () {
    expect(
      validarSenhaMensagem('senha123'),
      contains('1 letra maiúscula'),
    );
  });

  test('Senha sem numero retorna erro', () {
    expect(
      validarSenhaMensagem('Senhaaa'),
      contains('1 número'),
    );
  });
}