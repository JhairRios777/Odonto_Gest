// DashboardScreen — pantalla de inicio del odontólogo.
// Muestra: bienvenida, citas del día, accesos rápidos.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../agenda/views/nueva_cita_screen.dart';
import '../../expedientes/views/expediente_paciente_screen.dart';
import '../../expedientes/views/odontogram_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Demo data — reemplazar con llamadas a la API
  static const _citasHoy = [
    _CitaDemo(hora: '08:00', paciente: 'María López',    servicio: 'Limpieza dental',   status: 'Atendida',   color: AppColors.success),
    _CitaDemo(hora: '09:00', paciente: 'Carlos Ruiz',    servicio: 'Ortodoncia',         status: 'En curso',   color: AppColors.primary),
    _CitaDemo(hora: '10:00', paciente: 'Pedro Sánchez',  servicio: 'Extracción molar',  status: 'Pendiente',  color: AppColors.warning),
    _CitaDemo(hora: '11:00', paciente: 'Ana Martínez',   servicio: 'Blanqueamiento',    status: 'Confirmada', color: AppColors.info),
    _CitaDemo(hora: '14:00', paciente: 'José Herrera',   servicio: 'Corona porcelana',  status: 'Pendiente',  color: AppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatRow(),
                const SizedBox(height: 16),
                _buildAccesosRapidos(context),
                const SizedBox(height: 16),
                _buildCitasHoy(context),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NuevaCitaScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nueva Cita', style: AppTypography.buttonSmall(color: Colors.white)),
      ),
    );
  }

  // ── Header con gradiente ──────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withAlpha(51),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Rodríguez',
                            style: AppTypography.titleSmall(color: Colors.white)),
                        Text('Odontólogo General · Viernes 20 Jun',
                            style: AppTypography.caption(color: Colors.white70)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        title: Text('OdontoGest',
            style: AppTypography.titleSmall(color: Colors.white)),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
        collapseMode: CollapseMode.fade,
      ),
      backgroundColor: AppColors.primary,
    );
  }

  // ── Tarjetas de métricas ──────────────────────────────────────
  Widget _buildStatRow() {
    final stats = [
      _Stat('Citas hoy', '8', AppColors.primary, Icons.calendar_today),
      _Stat('Atendidas', '3', AppColors.success, Icons.check_circle_outline),
      _Stat('Pendientes', '5', AppColors.warning, Icons.pending_outlined),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: AppCard(
            margin: EdgeInsets.only(right: s == stats.last ? 0 : 8, bottom: 0),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, color: s.color, size: 22),
                const SizedBox(height: 6),
                Text(s.value,
                    style: AppTypography.headlineSmall(color: s.color)),
                Text(s.label,
                    style: AppTypography.captionXs(color: AppColors.textMuted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Accesos rápidos ───────────────────────────────────────────
  Widget _buildAccesosRapidos(BuildContext context) {
    final accesos = [
      _Acceso('Odontograma', Icons.grid_view_rounded, AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OdontogramScreen()))),
      _Acceso('Nuevo Paciente', Icons.person_add_outlined, AppColors.success,
          () {}),
      _Acceso('Nueva Cita', Icons.calendar_month_outlined, AppColors.warning,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NuevaCitaScreen()))),
      _Acceso('Expediente', Icons.folder_open_outlined, AppColors.info,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpedientePacienteScreen()))),
    ];

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accesos rápidos',
              style: AppTypography.label(color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: accesos.map((a) => _AccesoWidget(acceso: a)).toList(),
          ),
        ],
      ),
    );
  }

  // ── Lista de citas del día ────────────────────────────────────
  Widget _buildCitasHoy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Citas de hoy',
                style: AppTypography.label(color: AppColors.textDark)),
            TextButton(
              onPressed: () {},
              child: Text('Ver todas',
                  style: AppTypography.labelSmall(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ..._citasHoy.map((cita) => _CitaCard(cita: cita, context: context)),
      ],
    );
  }
}

// ── Cita card ──────────────────────────────────────────────────
class _CitaCard extends StatelessWidget {
  const _CitaCard({required this.cita, required this.context});
  final _CitaDemo cita;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ExpedientePacienteScreen())),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Hora pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(cita.hora,
                style: AppTypography.labelSmall(color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              cita.paciente[0],
              style: AppTypography.labelSmall(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cita.paciente,
                    style: AppTypography.bodyMedium(color: AppColors.textDark)),
                Text(cita.servicio,
                    style: AppTypography.captionXs(color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(label: cita.status, color: cita.color),
        ],
      ),
    );
  }
}

class _AccesoWidget extends StatelessWidget {
  const _AccesoWidget({required this.acceso});
  final _Acceso acceso;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: acceso.onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: acceso.color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(acceso.icon, color: acceso.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(acceso.label,
              style: AppTypography.captionXs(color: AppColors.textDark),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Data models (demo) ────────────────────────────────────────
class _CitaDemo {
  const _CitaDemo({
    required this.hora,
    required this.paciente,
    required this.servicio,
    required this.status,
    required this.color,
  });
  final String hora, paciente, servicio, status;
  final Color color;
}

class _Stat {
  const _Stat(this.label, this.value, this.color, this.icon);
  final String label, value;
  final Color color;
  final IconData icon;
}

class _Acceso {
  const _Acceso(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
