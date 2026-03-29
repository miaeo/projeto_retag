import 'package:flutter/material.dart';
import '../../cores.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Text("Scanner"),
      ),
    );
  }
}