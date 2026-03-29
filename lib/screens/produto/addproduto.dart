import 'package:flutter/material.dart';
import '../../cores.dart';

class AddProdutoScreen extends StatelessWidget {
  const AddProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Text("Adicionar novo produto"),
      ),
    );
  }
}