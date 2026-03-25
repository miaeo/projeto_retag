import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'inicial.dart';
import 'login.dart';
import 'home.dart';
import 'cores.dart';
import 'cadastro.dart';
import 'esquecisenha.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retag',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryblue,
      ),

      initialRoute: "/",
      routes: {
        "/": (context) => const Inicial(),
        "/login": (context) => const Login(),
        "/home": (context) => const Home(),
        "/cadastro": (context) => const Cadastro(),
        "/esqueci": (context) => const EsqueciSenha(),
      },
    );
  }
}