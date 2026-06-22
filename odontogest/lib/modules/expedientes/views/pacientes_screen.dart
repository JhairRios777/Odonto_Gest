// PacientesScreen — listado de pacientes con búsqueda y filtro.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import 'expediente_paciente_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _pacientes = [
    _Paciente('Juan García',    '#00123', '+504 9876-5432', 'O+',  'Activo',   true),
    _Paciente('María López',    '#00089', '+504 8765-4321', 'A+',  'Activo',   true),
    _Paciente('Carlos Ruiz',    '#00090', '+504 7654-3210', 'B-',  'Activo',   true),
    _Paciente('Pedro Sánchez',  '#00091', '+504 6543-2109', 'AB+', 'Activo',   false),
    _Paciente('Ana Martínez',   '#00092', '+504 5432-1098', 'O-',  'Activo',   true),
    _Paciente('Lucía Flores',   '#00093', '+504 4321-0987', 'A-',  'Activo',   false),
    _Paciente('José Herrera',   '#00094', '+504 3210-9876', 'B+',  'Activo',   true),
    _Paciente('Rosa Díaz',      '#00095', '+504 2109-8765', 'O+',  'Inactivo', false),
    _Paciente('Omar Torres',    '#00096', '+504 1098-7654', 'A+',  'Inactivo', false),
    _Paciente('Karla Ramos',    '#00097', '+504 0987-6543', 'AB-', 'Inactivo', false),
  ];

  List<_Paciente> get _filtrados => _pacientes
      .where((p) => p.nombre.toLowerCase().contains(_query.toLowerCase()) ||
                    p.expediente.contains(_query))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Pacientes',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Nuevo paciente',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildStats(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        style: AppTypography.body(color: AppColors.textDark),
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o expediente...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _StatChip('1,248 total', AppColors.textMuted),
          const SizedBox(width: 8),
          _StatChip('1,104 activos', AppColors.success),
          const SizedBox(width: 8),
          _StatChip('8 nuevos / mes', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildList() {
    final lista = _filtrados;
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search, size: 64, color: AppColors.border),
            const SizedBox(height: 12),
            Text('No se encontraron pacientes',
                style: AppTypography.body(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: lista.length,
      itemBuilder: (_, i) => _PacienteCard(paciente: lista[i]),
    );
  }
}

class _PacienteCard extends StatelessWidget {
  const _PacienteCard({required this.paciente});
  final _Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final isActivo = paciente.status == 'Activo';
    return AppCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ExpedientePacienteScreen())),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar con inicial
          CircleAvatar(
            radius: 22,
            backgroundColor: isActivo ? AppColors.primaryLight : AppColors.background,
            child: Text(
              paciente.nombre[0],
              style: AppTypography.titleSmall(
                  color: isActivo ? AppColors.primary : AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(paciente.nombre,
                    style: AppTypography.bodyMedium(color: AppColors.textDark)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(paciente.expediente,
                        style: AppTypography.caption(color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(paciente.tipoSangre,
                          style: AppTypography.badge(color: AppColors.error)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(paciente.telefono,
                    style: AppTypography.caption(color: AppColors.textMuted)),
              ],
            ),
          ),
          // Status + odontograma badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: paciente.status,
                color: isActivo ? AppColors.success : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTypography.badge(color: color)),
    );
  }
}

class _Paciente {
  const _Paciente(this.nombre, this.expediente, this.telefono,
      this.tipoSangre, this.status, this.citaHoy);
  final String nombre, expediente, telefono, tipoSangre, status;
  final bool citaHoy;
}
