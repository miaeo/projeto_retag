import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cores.dart';
import 'utils/validadores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  bool senhaVisivel = false;
  bool confirmarSenhaVisivel = false;
  bool carregando = false;
  bool temMaiuscula = false;
  bool temNumero = false;
  bool tamanhoOk = false;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  String erro = "";

  Future<void> cadastrar() async {
    setState(() {
      carregando = true;
      erro = "";
    });

    try {
      final senhaErro = validarSenhaMensagem(senhaController.text);

      if (senhaErro.isNotEmpty) {
        throw Exception(senhaErro);
      }

      if (senhaController.text != confirmarSenhaController.text) {
        throw Exception("Senhas não coincidem");
      }

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      await cred.user!.updateDisplayName(nomeController.text.trim());
      await cred.user!.reload();

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        erro = "Email já cadastrado";
      } else if (e.code == 'weak-password') {
        erro = "Senha não atende aos requisitos";
      } else if (e.code == 'invalid-email') {
        erro = "Email inválido";
      } else {
        erro = "Erro ao cadastrar";
      }
    } catch (e) {
      erro = e.toString().replaceAll("Exception: ", "");
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> cadastroGoogle() async {
    setState(() {
      carregando = true;
      erro = "";
    });

    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => carregando = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      await userCredential.user!.reload();

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      erro = "Erro ao cadastrar com Google";
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Opacity(
              opacity: carregando ? 0.5 : 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      30,
                      0,
                      30,
                      MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
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
                                  "Registrar-se",
                                  style: GoogleFonts.inter(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            TextField(
                              controller: nomeController,
                              cursorColor: AppColors.primaryblue,
                              decoration: InputDecoration(
                                hintText: "Nome",
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

                            const SizedBox(height: 30),

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

                            const SizedBox(height: 30),

                            TextField(
                              controller: senhaController,
                              obscureText: !senhaVisivel,
                              cursorColor: AppColors.primaryblue,
                              onChanged: (value) {
                                setState(() {
                                  erro = validarSenhaMensagem(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Senha",
                                hintStyle:
                                GoogleFonts.inter(color: Colors.black26),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      senhaVisivel = !senhaVisivel;
                                    });
                                  },
                                  icon: Icon(
                                    senhaVisivel
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.grayscale,
                                  ),
                                ),
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

                            const SizedBox(height: 30),

                            TextField(
                              controller: confirmarSenhaController,
                              obscureText: !confirmarSenhaVisivel,
                              cursorColor: AppColors.primaryblue,
                              decoration: InputDecoration(
                                hintText: "Confirmar senha",
                                hintStyle:
                                GoogleFonts.inter(color: Colors.black26),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      confirmarSenhaVisivel =
                                      !confirmarSenhaVisivel;
                                    });
                                  },
                                  icon: Icon(
                                    confirmarSenhaVisivel
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.grayscale,
                                  ),
                                ),
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
                                  duration:
                                  const Duration(milliseconds: 200),
                                  opacity: erro.isNotEmpty ? 1 : 0,
                                  child: Text(
                                    erro,
                                    style: GoogleFonts.inter(
                                      color: AppColors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            GestureDetector(
                              onTap: carregando ? null : cadastrar,
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryblue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Criar nova conta",
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
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Já sou cadastrado",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black38,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.lightgray),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "ou",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.lightgray),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap:
                              carregando ? null : cadastroGoogle,
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightgray,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/google.png",
                                      height: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Cadastrar-se com Google",
                                      style: GoogleFonts.rubik(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            Padding(
                              padding:
                              const EdgeInsets.only(bottom: 15),
                              child: Text(
                                "@ 2026 IFRN. Todos os direitos reservados.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.grayscale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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