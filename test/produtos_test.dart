import 'package:retag/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Produtos', () {

    test('Formatar data nula', () {
      expect(
        formatarData(null),
        'dd/mm/aaaa',
      );
    });

    test('Formatar data válida', () {
      expect(
        formatarData(DateTime(2026, 6, 10)),
        '10/6/2026',
      );
    });

    test('Status vencido', () {
      final data = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(
        getStatusValidade(data),
        'vencido',
      );
    });

    test('Status proximo do vencimento', () {
      final data = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 2)),
      );

      expect(
        getStatusValidade(data),
        'proximo',
      );
    });

    test('Status normal', () {
      final data = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 10)),
      );

      expect(
        getStatusValidade(data),
        'ok',
      );
    });

    test('Status sem validade', () {
      expect(
        getStatusValidade(null),
        'ok',
      );
    });

  });
}