import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cores.dart';
import '../../services/mqtt_service.dart';

class AddEtiquetaScreen extends StatefulWidget {
  const AddEtiquetaScreen({super.key});

  @override
  State<AddEtiquetaScreen> createState() => _AddEtiquetaScreenState();

}

class _AddEtiquetaScreenState extends State<AddEtiquetaScreen> {

  final idController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;
  final mqtt = MqttService();

  String? produtoSelecionadoId;
  String? produtoSelecionadoNome;

  double preco = 0.0;

  bool carregando = false;

  Future<void> salvarEtiqueta() async {
    if (user == null) return;

    if (idController.text.trim().isEmpty) {
      _erro("Informe o ID da etiqueta");
      return;
    }

    if (produtoSelecionadoId == null) {
      _erro("Selecione um produto");
      return;
    }

    setState(() => carregando = true);

    try {
      final etiquetaId = idController.text
          .trim()
          .toLowerCase()
          .replaceAll(' ', '');

      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("etiquetas")
          .doc(etiquetaId);

      final doc = await docRef.get();

      if (doc.exists) {
        _erro("Já existe uma etiqueta com esse ID");
        setState(() => carregando = false);
        return;
      }

      await docRef.set({
        "id": etiquetaId,
        "produtoId": produtoSelecionadoId,
        "nome": produtoSelecionadoNome,
        "preco": preco,
        "online": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/home",
            (route) => false,
        arguments: 3,
      );
    } catch (e) {
      print("ERRO FIRESTORE:");
      print(e);

      _erro(e.toString());
    }

    if (mounted) {
      setState(() => carregando = false);
    }
  }

  void _erro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red,
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
                  (route) => false,
              arguments: 3,
            );
          },
        ),
        centerTitle: true,
        title: Text(
          "Nova Etiqueta",
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

      body: user == null
          ? const Center(
        child: Text("Usuário não logado"),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("produtos")
            .orderBy("nome")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum produto cadastrado",
              ),
            );
          }

          final produtos = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _campo(
                  "ID da etiqueta *",
                  idController,
                ),

                Text(
                  "Produto *",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightgray,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: produtoSelecionadoId,
                      isExpanded: true,
                      hint: const Text(
                        "Selecione um produto",
                      ),
                      items: produtos.map((doc) {
                        final data =
                        doc.data() as Map<String, dynamic>;

                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            data["nome"] ?? "",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final produto = produtos.firstWhere(
                              (p) => p.id == value,
                        );

                        final data =
                        produto.data()
                        as Map<String, dynamic>;

                        setState(() {
                          produtoSelecionadoId = produto.id;
                          produtoSelecionadoNome =
                          data["nome"];

                          preco =
                              (data["preco"] ?? 0)
                                  .toDouble();
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Preço",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightgray,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Text(
                    "R\$ ${preco.toStringAsFixed(2)}",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: carregando
                      ? null
                      : salvarEtiqueta,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryblue,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        carregando
                            ? "Criando..."
                            : "Criar etiqueta",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _campo(
      String label,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightgray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}