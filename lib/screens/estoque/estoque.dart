import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cores.dart';
import '../produto/addproduto.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  int? expandedIndex;

  final user = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();

  String formatarData(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final data = timestamp.toDate();
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
          "Estoque",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AddProdutoScreen(),
                  ),
                );
                setState(() {});
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
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
          ? const Center(child: Text("Usuário não logado"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("produtos")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum produto no estoque"));
          }

          final produtos = snapshot.data!.docs;

          final query = searchController.text.toLowerCase();

          final produtosFiltrados = produtos.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final nome = (data["nome"] ?? "").toString().toLowerCase();
            final codigo = (data["codigoBarras"] ?? "").toString().toLowerCase();

            return nome.contains(query) || codigo.contains(query);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _barraPesquisa(),
                const SizedBox(height: 12),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: ListView.builder(
                      key: ValueKey(produtosFiltrados.length),
                      itemCount: produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final doc = produtosFiltrados[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final isExpanded = expandedIndex == index;

                        return _itemProduto(
                          id: doc.id,
                          nome: data["nome"] ?? "",
                          preco: (data["preco"] ?? 0).toDouble(),
                          quantidade: data["quantidade"] ?? 0,
                          codigo: data["codigoBarras"],
                          validade: data["validade"],
                          producao: data["producao"],
                          expanded: isExpanded,
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                        );
                      },
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

  Widget _itemProduto({
    required String id,
    required String nome,
    required double preco,
    required int quantidade,
    required String? codigo,
    required Timestamp? validade,
    required Timestamp? producao,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    final status = getStatusValidade(validade);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(id),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: expanded ? 0.25 : 0.5,
          children: [
            _botaoAcao(
              icon: Icons.edit,
              color: AppColors.primaryblue,
              onTap: () {},
            ),
            _botaoAcao(
              icon: Icons.delete_outline,
              color: AppColors.red,
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user!.uid)
                    .collection("produtos")
                    .doc(id)
                    .delete();
              },
            ),
          ],
        ),

        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightgray,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.gray,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "$quantidade  ",
                                  style: const TextStyle(
                                    color: AppColors.primaryblue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                  text: "em estoque",
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _statusBolinha(status),
                        const SizedBox(height: 6),
                        Text(
                          "R\$ ${preco.toStringAsFixed(2)}",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (expanded) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),

                  if (codigo != null && codigo.toString().trim().isNotEmpty)
                    _infoLinha("Código de barras", codigo),

                  if (validade != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            "Validade: ",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            formatarData(validade),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 6),
                          _statusBolinha(status, comIcone: true),
                        ],
                      ),
                    ),

                  if (producao != null)
                    _infoLinha("Produção", formatarData(producao)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barraPesquisa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightgray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.gray, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Pesquisar",
                hintStyle: GoogleFonts.inter(color: AppColors.gray),
                border: InputBorder.none,
              ),
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLinha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$titulo: ",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAcao({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _statusBolinha(String status, {bool comIcone = false}) {
    Color cor;

    if (status == "vencido") {
      cor = AppColors.red;
    } else if (status == "proximo") {
      cor = AppColors.yellow;
    } else {
      cor = Colors.transparent;
    }

    if (status == "ok") return const SizedBox();

    return Container(
      width: comIcone ? 18 : 10,
      height: comIcone ? 18 : 10,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
      ),
      child: comIcone
          ? const Center(
        child: Text(
          "!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
    );
  }
}