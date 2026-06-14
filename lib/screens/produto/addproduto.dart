import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cores.dart';
import '/../utils/validadores.dart';

class AddProdutoScreen extends StatefulWidget {
  const AddProdutoScreen({super.key});

  @override
  State<AddProdutoScreen> createState() => _AddProdutoScreenState();
}

class _AddProdutoScreenState extends State<AddProdutoScreen> {
  final nomeController = TextEditingController();
  final codigoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final precoController = TextEditingController();

  DateTime? validade;
  DateTime? producao;

  bool carregando = false;

  Future<void> salvarProduto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (nomeController.text.trim().isEmpty) {
      _erro("Dê um nome ao seu produto");
      return;
    }

    if (quantidadeController.text.trim().isEmpty ||
        int.tryParse(quantidadeController.text) == null) {
      _erro("Informe uma quantidade válida");
      return;
    }

    if (precoController.text.trim().isEmpty ||
        double.tryParse(precoController.text) == null) {
      _erro("Informe um preço válido");
      return;
    }

    if (validade == null) {
      _erro("Selecione a data de validade");
      return;
    }

    setState(() => carregando = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("produtos")
          .add({
        "nome": nomeController.text,
        "codigoBarras": codigoController.text,
        "quantidade": int.parse(quantidadeController.text),
        "preco": double.parse(precoController.text),
        "validade": validade,
        "producao": producao,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/home",
            (route) => false,
        arguments: 1,
      );
    } catch (e) {
      _erro("Erro ao salvar produto");
    }

    setState(() => carregando = false);
  }

  void _erro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red,
      ),
    );
  }

  Future<void> selecionarData(bool isValidade) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        if (isValidade) {
          validade = data;
        } else {
          producao = data;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
                  (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: Text(
          "Adicionar novo item",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Column(
            children: [
              Container(height: 1, color: AppColors.grayline),
              Container(
                height: 5,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grayline.withOpacity(0.8),
                      blurRadius: 3,
                      offset: const Offset(0, 0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _campo("Nome *", nomeController),
            _campoCodigoBarras(),

            Row(
              children: [
                Expanded(child: _campo("Quantidade *", quantidadeController)),
                const SizedBox(width: 10),
                Expanded(child: _campo("Valor unitário *", precoController)),
              ],
            ),

            const SizedBox(height: 12),

            _campoData("Data de validade *", validade, () => selecionarData(true)),
            _campoData("Data de produção", producao, () => selecionarData(false)),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: carregando ? null : salvarProduto,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryblue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Adicionar ao estoque",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightgray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _campoData(String label, DateTime? data, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightgray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatarData(data), style: GoogleFonts.inter(fontSize: 16),),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.gray),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  Widget _campoCodigoBarras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Código de barras",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightgray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/home",
                        (route) => false,
                    arguments: 5,
                  );
                },
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

