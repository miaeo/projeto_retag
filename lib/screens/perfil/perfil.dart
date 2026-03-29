import 'package:flutter/material.dart';
import '../../cores.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Text("Perfil"),
      ),
    );
  }
}