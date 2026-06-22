// AgendaScreen — lista de citas del día con filtros por estado.
// El odontólogo ve sus citas; admin ve todas las citas de la clínica.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import 'nueva_cita_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _filtros = ['Todas', 'Pendientes', 'Atendidas', 'Canceladas'];

  // Demo data — reemplazar con AgendaController → API
  final _citas = [
    _Cita('08:00', 'María López',   'Dr. Rodríguez', 'Limpieza dental',   'Atendida',   AppColors.success),
    _Cita('09:00', 'Carlos Ruiz',   'Dra. Flores',   'Ortodoncia',        'En curso',   AppColors.primary),
    _Cita('10:00', 'Pedro Sánchez', 'Dr. Rodríguez', 'Extracción molar',  'Pendiente',  AppColors.warning),
    _Cita('11:00', 'Ana Martínez',  'Dra. Flores',   'Blanqueamiento',    'Confirmada', AppColors.info),
    _Cita('12:00', 'Lucía Flores',  'Dr. Medina',    'Revisión general',  'Pendiente',  AppColors.warning),
    _Cita('14:00', 'José Herrera',  'Dr. Rodríguez', 'Corona porcelana',  'Confirmada', AppColors.info),
    _Cita('15:00', 'Rosa Díaz',     'Dra. Flores',   'Implante dental',   'Pendiente',  AppColors.warning),
    _Cita('16:00', 'Omar Torres',   'Dr. Medina',    'Canal radicular',   'Cancelada',  AppColors.error),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filtros.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Cita> _filtradas(String filtro) {
    if (filtro == 'Todas') return _citas;
    return _citas.where((c) => c.status.contains(filtro.replaceAll('s', ''))).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Agenda de Citas',
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Ir a hoy',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: AppTypography.labelSmall(),
          tabs: _filtros.map((f) => Tab(text: f)).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _filtros.map((filtro) {
                final lista = _filtradas(filtro);
                if (lista.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: lista.length,
                  itemBuilder: (_, i) => _CitaCard(cita: lista[i]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NuevaCitaScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nueva Cita',
            style: AppTypography.buttonSmall(color: Colors.white)),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Viernes, 20 de Junio 2025',
              style: AppTypography.bodyMedium(color: AppColors.primary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${_citas.length} citas',
                style: AppTypography.badge(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, size: 64, color: AppColors.border),
          const SizedBox(height: 12),
          Text('Sin citas en este filtro',
              style: AppTypography.body(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _CitaCard extends StatelessWidget {
  const _CitaCard({required this.cita});
  final _Cita cita;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Franja de color izquierda
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: cita.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Hora
          Column(
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cita.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(cita.hora,
                    style: AppTypography.labelSmall(color: cita.color)),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cita.paciente,
                    style: AppTypography.bodyMedium(color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(cita.doctor,
                    style: AppTypography.captionXs(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(cita.servicio,
                          style: AppTypography.captionXs(
                              color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status + acciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: cita.status, color: cita.color),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionBtn(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.close,
                    color: AppColors.error,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _Cita {
  const _Cita(this.hora, this.paciente, this.doctor, this.servicio,
      this.status, this.color);
  final String hora, paciente, doctor, servicio, status;
  final Color color;
}
