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