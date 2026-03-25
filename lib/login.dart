import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class CustomToggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? AppColors.secondaryblue
              : AppColors.lightgray,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment:
          value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginState extends State<Login> {
  bool senhaVisivel = false;
  bool lembrar = false;
  bool carregando = false;
  String erro = "";

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarEmail();
  }

  Future<void> carregarEmail() async {
    final prefs = await SharedPreferences.getInstance();

    final emailSalvo = prefs.getString('email');
    final lembrarSalvo = prefs.getBool('lembrar') ?? false;

    if (lembrarSalvo && emailSalvo != null) {
      emailController.text = emailSalvo;
      setState(() {
        lembrar = true;
      });
    }
  }

  Future<void> login() async {
    final start = DateTime.now();

    setState(() {
      carregando = true;
      erro = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final diff = DateTime.now().difference(start);
      if (diff.inMilliseconds < 1000) {
        await Future.delayed(
          Duration(milliseconds: 1000 - diff.inMilliseconds),
        );
      }

      final prefs = await SharedPreferences.getInstance();

      if (lembrar) {
        await prefs.setString('email', emailController.text.trim());
        await prefs.setBool('lembrar', true);
      } else {
        await prefs.remove('email');
        await prefs.setBool('lembrar', false);
      }

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() {
        erro = "Email ou senha incorretos";
      });

    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      print("Erro Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  Hero(
                    tag: "logo",
                    child: Image.asset(
                      "assets/logo.png",
                      height: 90,
                    ),
                  ),

                  const SizedBox(height: 50),

                  TextField(
                    controller: emailController,
                    cursorColor: AppColors.primaryblue,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: GoogleFonts.inter(color: Colors.black26),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grayblue, width: 2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryblue, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: senhaController,
                    obscureText: !senhaVisivel,
                    cursorColor: AppColors.primaryblue,
                    decoration: InputDecoration(
                      hintText: "Senha",
                      hintStyle: GoogleFonts.inter(color: Colors.black26),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            senhaVisivel = !senhaVisivel;
                          });
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            senhaVisivel
                                ? Icons.visibility_off
                                : Icons.visibility,
                            key: ValueKey(senhaVisivel),
                            color: AppColors.grayscale,
                          ),
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grayblue, width: 2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryblue, width: 2),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 30,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSlide(
                        offset: erro.isNotEmpty ? Offset(0, 0) : Offset(0, -0.2),
                        duration: Duration(milliseconds: 200),
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

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomToggle(
                            value: lembrar,
                            onChanged: (value) {
                              setState(() {
                                lembrar = value;
                              });
                            },
                          ),
                          Text(
                            "   Lembre-se de mim",
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/esqueci");
                        },
                        child: Text(
                          "Esqueceu a senha?",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: carregando ? null : login,
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryblue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Entrar",
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Novo usuário? ",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/cadastro");
                        },
                        child: Text(
                          "Crie sua conta",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.lightgray),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "ou",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppColors.lightgray),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: carregando ? null : loginGoogle,
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightgray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/google.png", height: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Continuar com Google",
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

          if (carregando) ...[
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: const LinearProgressIndicator(
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}