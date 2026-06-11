import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cores.dart';
import '../../services/mqtt_service.dart';
import 'addetiqueta.dart';

class EtiquetasScreen extends StatefulWidget {
  const EtiquetasScreen({super.key});

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  final MqttService mqtt = MqttService();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    await mqtt.connect();

    print("Registrando listener");

    mqtt.listenMessages((message) async {
      print("MQTT RECEBIDO:");
      print(message);

      try {
        final data = jsonDecode(message);

        if (data["action"] == "connect") {
          print("CONNECT RECEBIDO");

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("etiquetas")
              .doc(data["id"])
              .update({
            "online": true,
          });
        }

        if (data["action"] == "disconnect") {
          print("DISCONNECT RECEBIDO");

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("etiquetas")
              .doc(data["id"])
              .update({
            "online": false,
          });
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  void _send(Map<String, dynamic> data) {
    mqtt.sendMessage(jsonEncode(data));
  }

  Future<void> _deleteEtiqueta(String id) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("etiquetas")
        .doc(id)
        .delete();

    _send({
      "action": "delete",
      "id": id,
    });
  }

  Future<void> _updateEtiqueta(
      String id,
      String nome,
      double preco,
      bool online,
      ) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("etiquetas")
        .doc(id)
        .update({
      "nome": nome,
      "preco": preco,
      "online": online,
    });

    _send({
      "action": "update",
      "id": id,
      "nome": nome,
      "preco": preco,
      "online": online,
    });
  }

  void _enviarParaLCD(Map<String, dynamic> item) {

    if (!(item["online"] ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nenhum LCD conectado a esta etiqueta",
          ),
        ),
      );
      return;
    }

    _send({
      "action": "display",
      "id": item["id"],
      "nome": item["nome"],
      "preco": item["preco"],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            children: [
              const TextSpan(
                text: "Etiqueta ",
              ),
              TextSpan(
                text: item["id"].toString().toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const TextSpan(
                text: " enviada ao LCD",
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final nomeC =
    TextEditingController(text: item["nome"]);

    final precoC =
    TextEditingController(text: item["preco"].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Etiqueta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeC),
            TextField(controller: precoC),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateEtiqueta(
                item["id"],
                nomeC.text,
                double.tryParse(precoC.text) ??
                    item["preco"],
                item["online"] ?? false,
              );

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Usuário não logado"),
        ),
      );
    }

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
            );
          },
        ),

        centerTitle: true,
        title: Text(
          "Etiquetas",
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
                    const AddEtiquetaScreen(),
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
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Column(
            children: [
              Container(
                height: 1,
                color: AppColors.grayline,
              ),
              Container(
                height: 5,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grayline
                          .withOpacity(0.8),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("etiquetas")
            .orderBy("createdAt", descending: true)
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
                "Nenhuma etiqueta cadastrada",
              ),
            );
          }

          final etiquetas = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: etiquetas.length,
              itemBuilder: (context, index) {
                final item =
                etiquetas[index].data()
                as Map<String, dynamic>;

                return _item(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _item(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item["id"]),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.5,
          children: [
            _botaoAcao(
              icon: Icons.edit,
              color: AppColors.primaryblue,
              onTap: () => _showEditDialog(item),
            ),
            _botaoAcao(
              icon: Icons.delete_outline,
              color: AppColors.red,
              onTap: () => _deleteEtiqueta(item["id"]),
            ),
          ],
        ),

        child: GestureDetector(
          onTap: () => _enviarParaLCD(item),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightgray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["id"] ?? "",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item["nome"] ?? "",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (item["online"] ?? false)
                            ? AppColors.green
                            : AppColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "R\$ ${(item["preco"] ?? 0).toDouble().toStringAsFixed(2)}",
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
          ),
        ),
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
            size: 28,
          ),
        ),
      ),
    );
  }
}
