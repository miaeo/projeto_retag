import 'package:cloud_firestore/cloud_firestore.dart';

String formatarData(DateTime? data) {
  if (data == null) return "dd/mm/aaaa";
  return "${data.day}/${data.month}/${data.year}";
}

String getStatusValidade(Timestamp? validade) {
  if (validade == null) return "ok";

  final hoje = DateTime.now();
  final data = validade.toDate();

  final diferenca = data.difference(hoje).inDays;

  if (diferenca < 0) return "vencido";
  if (diferenca <= 3) return "proximo";

  return "ok";
}

String validarSenhaMensagem(String senha) {
  List<String> erros = [];

  if (senha.length < 6) {
    erros.add("mín. 6 caracteres");
  }

  if (!RegExp(r'[A-Z]').hasMatch(senha)) {
    erros.add("1 letra maiúscula");
  }

  if (!RegExp(r'[0-9]').hasMatch(senha)) {
    erros.add("1 número");
  }

  if (erros.isEmpty) return "";

  return "Senha precisa de: ${erros.join(", ")}";
}