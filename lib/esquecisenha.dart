import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cores.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EsqueciSenha extends StatefulWidget {
  const EsqueciSenha({super.key});

  @override
  State<EsqueciSenha> createState() => _EsqueciSenhaState();
}

class _EsqueciSenhaState extends State<EsqueciSenha> {
  final emailController = TextEditingController();

  bool carregando = false;
  String erro = "";
  String sucesso = "";

  Future<void> redefinirSenha() async {
    setState(() {
      carregando = true;
      erro = "";
      sucesso = "";
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      sucesso = "Se este email estiver cadastrado, você receberá instruções para redefinir sua senha.";

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        erro = "Email inválido";
      } else {
        erro = "Erro ao enviar email";
      }
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Opacity(
              opacity: carregando ? 0.5 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Row(
                      children: [
                        Hero(
                          tag: "logo",
                          child: Image.asset(
                            "assets/logo.png",
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Redefinir senha",
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Insira seu endereço de e-mail e lhe enviaremos instruções para redefinir sua senha.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: emailController,
                      cursorColor: AppColors.primaryblue,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle:
                        GoogleFonts.inter(color: Colors.black26),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.grayblue, width: 2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.primaryblue, width: 2),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity:
                          (erro.isNotEmpty || sucesso.isNotEmpty)
                              ? 1
                              : 0,
                          child: Text(
                            erro.isNotEmpty ? erro : sucesso,
                            style: GoogleFonts.inter(
                              color: erro.isNotEmpty
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: carregando ? null : redefinirSenha,
                      child: Container(
                        width: 280,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryblue,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Continuar",
                            style: GoogleFonts.rubik(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Voltar para login",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black38,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        "@ 2026 IFRN. Todos os direitos reservados.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.grayscale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (carregando)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 4,
                color: AppColors.primaryblue,
                backgroundColor: AppColors.secondaryblue,
              ),
            ),
        ],
      ),
    );
  }
}