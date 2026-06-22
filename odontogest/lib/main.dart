import 'package:flutter/material.dart';
import 'core/constants/app_assets.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'data/services/auth_service.dart';
import 'modules/seguridad/views/home_shell.dart';

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
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────
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

// ─── Login Screen ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMsg;

  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // ── Lógica de login ──────────────────────────────────────────
  Future<void> _handleLogin() async {
    final usuario    = _userController.text.trim();
    final contrasena = _passController.text;

    if (usuario.isEmpty || contrasena.isEmpty) {
      setState(() => _errorMsg = 'Completa usuario y contraseña');
      _showSnackBar('Completa todos los campos', isError: true);
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });

    final result = await AuthService.login(
      usuario:    usuario,
      contrasena: contrasena,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      _showSnackBar('Bienvenido, \${result.nombre ?? usuario} ✓', isError: false);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      // El rol lo decide el backend — nunca el usuario
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeShell(rol: result.rol ?? 'Odontologo'),
        ),
      );
    } else {
      setState(() => _errorMsg = result.errorMsg);
      _showSnackBar(result.errorMsg ?? 'Error al iniciar sesión', isError: true);
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
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
            // ── Header con ola ──
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

                  // ── Campo usuario ──
                  Text(AppStrings.labelUser,
                      style: AppTypography.label(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    enabled: !_loading,
                    textInputAction: TextInputAction.next,
                    style: AppTypography.body(color: AppColors.textDark),
                    decoration: _inputDeco(),
                  ),
                  const SizedBox(height: 20),

                  // ── Campo contraseña ──
                  Text(AppStrings.labelPassword,
                      style: AppTypography.label(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passController,
                    obscureText: _obscurePassword,
                    enabled: !_loading,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    style: AppTypography.body(color: AppColors.textDark),
                    decoration: _inputDeco(
                      suffix: IconButton(
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
                    ),
                  ),

                  // ── Mensaje de error ──
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withAlpha(80), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: AppTypography.captionXs(
                                  color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Botón login ──
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          disabledBackgroundColor:
                              AppColors.primary.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                AppStrings.btnLogin,
                                style: AppTypography.button(
                                    color: AppColors.surface),
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

  InputDecoration _inputDeco({Widget? suffix}) => InputDecoration(
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      );
}
