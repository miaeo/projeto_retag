import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../cores.dart';

class EtiquetasScreen extends StatefulWidget {
  const EtiquetasScreen({super.key});

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {

  final List<Map<String, dynamic>> etiquetas = [
    {"id": "Label001", "nome": "Arroz 5KG", "preco": 24.90, "online": true},
    {"id": "Label002", "nome": "Feijão", "preco": 8.49, "online": false},
    {"id": "Label003", "nome": "Macarrão", "preco": 4.59, "online": true},
    {"id": "Label004", "nome": "Açúcar", "preco": 3.99, "online": true},
  ];

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
              onTap: () {
                // todo: adicionar etiqueta
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
        child: ListView.builder(
          itemCount: etiquetas.length,
          itemBuilder: (context, index) {
            final item = etiquetas[index];

            return _itemEtiqueta(
              id: item["id"],
              nome: item["nome"],
              preco: item["preco"],
              online: item["online"],
            );
          },
        ),
      ),
    );
  }

  Widget _itemEtiqueta({
    required String id,
    required String nome,
    required double preco,
    required bool online,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(id),

        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.5,

          children: [
            _botaoAcao(
              icon: Icons.edit,
              color: AppColors.primaryblue,
              onTap: () {
                // todo: editar
              },
            ),
            _botaoAcao(
              icon: Icons.link_off_outlined,
              color: AppColors.red,
              onTap: () {
                // todo: desconectar
              },
            ),
          ],
        ),

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nome,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: online ? AppColors.green : AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
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
