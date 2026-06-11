import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../cores.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Column(
            children: [
              Container(
                height: 1,
                color: AppColors.grayline,
              ),

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
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 20),
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
          "Perfil",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _perfilHeader(),
              const SizedBox(height: 20),

              _item("Detalhes do perfil", Icons.person),
              _item("Dispositivos", Icons.devices_rounded),
              _item("Configurações", Icons.settings),
              _item("Notificações", Icons.notifications_rounded),

              const SizedBox(height: 5),
              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 16),

              _item("Suporte", Icons.support),
              _item(
                "Logout",
                Icons.logout,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _perfilHeader() {
    final user = FirebaseAuth.instance.currentUser;

    String nome = "Usuário";
    String email = "email@exemplo.com";

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nome = user.displayName!;
      }

      if (user.email != null && user.email!.isNotEmpty) {
        email = user.email!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightgray,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryblue,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 35,
                  color: AppColors.secondaryblue,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryblue,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _item(String titulo, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.lightgray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryblue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}