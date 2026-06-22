import 'package:flutter/material.dart';
import 'core/constants/app_assets.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart'; // tokens centralizados: AppColors, AppTypography, AppTheme

void main() {
  runApp(const OdontoGestApp());
}

class OdontoGestApp extends StatelessWidget {
  const OdontoGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      // AppTheme.light() consume todos los tokens de app_theme.dart
      // Para cambiar colores/fuentes de toda la app, editar app_theme.dart
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.cubicTo(
      size.width * 0.35, size.height + 20,
      size.width * 0.65, size.height - 90,
      size.width, size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

// ─── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: screenHeight * 0.45,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Image.asset(
                      AppAssets.logo,
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // ── Formulario ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.loginTitle,
                    style: AppTypography.headline(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),

                  // Usuario
                  Text(
                    AppStrings.labelUser,
                    style: AppTypography.label(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    style: AppTypography.body(color: AppColors.textDark),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contraseña
                  Text(
                    AppStrings.labelPassword,
                    style: AppTypography.label(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passController,
                    obscureText: _obscurePassword,
                    style: AppTypography.body(color: AppColors.textDark),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        // TODO: reemplazar con AuthController.login() cuando exista
                        // El backend retorna el rol asignado; NUNCA lo elige el usuario
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          AppStrings.btnLogin,
                          style: AppTypography.button(color: AppColors.surface),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      AppStrings.version,
                      style: AppTypography.caption(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
