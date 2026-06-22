// PerfilScreen — configuración y cierre de sesión del usuario autenticado.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const _menuItems = [
    _MenuItem('Mi perfil',          Icons.person_outline,        false),
    _MenuItem('Notificaciones',     Icons.notifications_outlined, false),
    _MenuItem('Cambiar contraseña', Icons.lock_outline,          false),
    _MenuItem('Idioma',             Icons.language_outlined,      false),
    _MenuItem('Sobre la clínica',   Icons.local_hospital_outlined,false),
    _MenuItem('Cerrar sesión',      Icons.logout,                 true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Mi Perfil'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  ..._menuItems.map((item) => _MenuCard(item: item,
                      onTap: item.isDestructive
                          ? () => _confirmLogout(context)
                          : () {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: const BoxDecoration(gradient: AppGradients.primaryVertical),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withAlpha(51),
            child: const Icon(Icons.person, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 12),
          Text('Dr. Admin García',
              style: AppTypography.title(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Administrador · Clínica Dental Paz',
              style: AppTypography.caption(color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('admin@clinicapaz.hn',
                style: AppTypography.captionXs(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        title: Text('Cerrar sesión',
            style: AppTypography.titleSmall(color: AppColors.textDark)),
        content: Text('¿Está seguro que desea cerrar sesión?',
            style: AppTypography.body(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: AppTypography.buttonSmall(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: AuthController.logout() → limpiar token → ir a Login
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Cerrar sesión',
                style: AppTypography.buttonSmall(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onTap});
  final _MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? AppColors.error : AppColors.textDark;
    final iconBg  = item.isDestructive ? AppColors.errorLight : AppColors.primaryLight;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(item.label,
                style: AppTypography.bodyMedium(color: color)),
          ),
          Icon(Icons.chevron_right,
              color: item.isDestructive ? AppColors.error : AppColors.textMuted,
              size: 20),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.isDestructive);
  final String label;
  final IconData icon;
  final bool isDestructive;
}
