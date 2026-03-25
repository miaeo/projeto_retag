import 'package:flutter/material.dart';
import 'cores.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  Widget telaInicio() {
    final user = FirebaseAuth.instance.currentUser;
    String nome = "Usuário";

    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      nome = user.displayName!;
    }

    return Center(
      child: Text(
        "Olá, $nome!",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
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
                final isSelected = index == i;

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