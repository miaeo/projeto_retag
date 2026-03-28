import 'package:flutter/material.dart';
import 'cores.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

String formatarNome(String nome) {
  nome = nome.trim();
  if (nome.isEmpty) return "Usuário";
  List partes = nome.split(' ');
  String primeiro = partes.first;

  return primeiro[0].toUpperCase() +
      primeiro.substring(1).toLowerCase();
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class telaEscanear extends StatelessWidget {
  const telaEscanear({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Text("Escaneamento"),
      ),
    );
  }
}

class _HomeState extends State<Home> {
  int index = 0;

  Widget telaInicio() {
    final user = FirebaseAuth.instance.currentUser;
    String nome = "Usuário";

    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      nome = formatarNome(user.displayName!);
    }

    String getDataHoje() {
      final agora = DateTime.now();

      const diasSemana = [
        "segunda-feira",
        "terça-feira",
        "quarta-feira",
        "quinta-feira",
        "sexta-feira",
        "sábado",
        "domingo",
      ];

      const meses = [
        "janeiro",
        "fevereiro",
        "março",
        "abril",
        "maio",
        "junho",
        "julho",
        "agosto",
        "setembro",
        "outubro",
        "novembro",
        "dezembro",
      ];

      String diaSemana = diasSemana[agora.weekday - 1];
      String mes = meses[agora.month - 1];

      String data =
          "$diaSemana, ${agora.day} de $mes de ${agora.year}";

      return data[0].toUpperCase() + data.substring(1);
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: 10,
              child: Container(
                color: AppColors.bluebackground,
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Olá, $nome!",
                        style: GoogleFonts.inter(
                          color: AppColors.primaryblue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 28,
                        color: AppColors.primaryblue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getDataHoje(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primaryblue,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 145),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        index = 5;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(21),
                      decoration: BoxDecoration(
                        color: AppColors.purpleblue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Escaneamento rápido",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Escaneie um novo código de barras",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.qr_code_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Atalhos rápidos",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _atalhoItem(
                              Icons.qr_code_rounded,
                              "Scanner",
                              5,
                              AppColors.skyblue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _atalhoItem(
                              Icons.inventory,
                              "Estoque",
                              1,
                              AppColors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _atalhoItem(
                              Icons.add_outlined,
                              "Novo produto",
                              2,
                              AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _atalhoItem(
                              Icons.sell_rounded,
                              "Etiquetas",
                              3,
                              AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _atalhoItem(
      IconData icon,
      String titulo,
      int destino,
      Color cor,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          index = destino;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryblue,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              titulo,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get telas => [
    telaInicio(),
    const Center(child: Text("Estoque")),
    const Center(child: Text("Adicionar novo produto")),
    const Center(child: Text("Etiquetas")),
    const Center(child: Text("Perfil")),
    telaEscanear(),
  ];

  final icons = [
    Icons.home,
    Icons.inventory,
    Icons.add_outlined,
    Icons.sell_rounded,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: telas[index],

      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.lightgray,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final isSelected = index == i && index < 5;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      index = i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(i == 2 ? 12 : 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondaryblue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icons[i],
                      size: i == 2 ? 32 : 26,
                      color: isSelected
                          ? AppColors.primaryblue
                          : AppColors.gray,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
