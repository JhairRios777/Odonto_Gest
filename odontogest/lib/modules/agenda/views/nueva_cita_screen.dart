// NuevaCitaScreen — formulario para registrar una nueva cita.
// Regla de negocio: 1 cita por hora; el recepcionista asigna día y hora.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _pacienteCtrl    = TextEditingController();
  final _motivoCtrl      = TextEditingController();
  final _obsCtrl         = TextEditingController();

  String? _doctorSeleccionado;
  String? _horaSeleccionada;
  DateTime? _fechaSeleccionada;

  static const _doctores = [
    'Dr. Rodríguez — General',
    'Dra. Flores — Ortodoncia',
    'Dr. Medina — Endodoncia',
  ];

  // Horas disponibles (1 cita por hora, las ocupadas se marcan)
  static const _horasDisponibles = [
    '07:00','08:00','09:00','10:00','11:00',
    '13:00','14:00','15:00','16:00','17:00',
  ];
  static const _horasOcupadas = {'09:00', '11:00', '14:00'};

  @override
  void dispose() {
    _pacienteCtrl.dispose();
    _motivoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Nueva Cita',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Paciente',
                hint: 'Buscar paciente...',
                controller: _pacienteCtrl,
                prefixIcon: Icons.person_search_outlined,
                validator: (v) => v!.isEmpty ? 'Seleccione un paciente' : null,
              ),
              const SizedBox(height: 14),

              _buildLabel('Odontólogo'),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _doctorSeleccionado,
                items: _doctores,
                hint: 'Seleccionar doctor',
                icon: Icons.medical_services_outlined,
                onChanged: (v) => setState(() => _doctorSeleccionado = v),
              ),
              const SizedBox(height: 14),

              _buildLabel('Fecha'),
              const SizedBox(height: 6),
              _buildDatePicker(context),
              const SizedBox(height: 14),

              _buildLabel('Hora disponible'),
              const SizedBox(height: 6),
              _buildHoraPicker(),
              const SizedBox(height: 14),

              _buildField(
                label: 'Motivo de consulta',
                hint: 'Descripción breve del motivo...',
                controller: _motivoCtrl,
                prefixIcon: Icons.medical_information_outlined,
                validator: (v) => v!.isEmpty ? 'Ingrese el motivo' : null,
              ),
              const SizedBox(height: 14),

              _buildField(
                label: 'Observaciones',
                hint: 'Notas adicionales (opcional)...',
                controller: _obsCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonRadius),
                    elevation: 0,
                  ),
                  child: Text('Guardar Cita',
                      style: AppTypography.button(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar',
                      style: AppTypography.body(color: AppColors.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers de UI ────────────────────────────────────────────
  Widget _buildLabel(String label) {
    return Text(label, style: AppTypography.label(color: AppColors.primary));
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.body(color: AppColors.textDark),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textMuted)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Row(children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(hint, style: AppTypography.body(color: AppColors.textMuted)),
      ]),
      items: items.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: onChanged,
      style: AppTypography.body(color: AppColors.textDark),
      decoration: const InputDecoration(),
      validator: (v) => v == null ? 'Seleccione un odontólogo' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
          locale: const Locale('es', 'HN'),
        );
        if (picked != null) setState(() => _fechaSeleccionada = picked);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: AppRadius.inputRadius,
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              _fechaSeleccionada == null
                  ? 'dd / mm / aaaa'
                  : '${_fechaSeleccionada!.day.toString().padLeft(2,'0')}/'
                    '${_fechaSeleccionada!.month.toString().padLeft(2,'0')}/'
                    '${_fechaSeleccionada!.year}',
              style: AppTypography.body(
                  color: _fechaSeleccionada == null
                      ? AppColors.textMuted
                      : AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoraPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _horasDisponibles.map((hora) {
        final ocupada = _horasOcupadas.contains(hora);
        final seleccionada = _horaSeleccionada == hora;
        return GestureDetector(
          onTap: ocupada ? null : () => setState(() => _horaSeleccionada = hora),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: ocupada
                  ? AppColors.background
                  : seleccionada
                      ? AppColors.primary
                      : AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ocupada
                    ? AppColors.border
                    : seleccionada
                        ? AppColors.primary
                        : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ocupada)
                  const Icon(Icons.block, size: 11, color: AppColors.textMuted),
                if (ocupada) const SizedBox(width: 4),
                Text(
                  hora,
                  style: AppTypography.labelSmall(
                    color: ocupada
                        ? AppColors.textMuted
                        : seleccionada
                            ? Colors.white
                            : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Acción guardar ────────────────────────────────────────────
  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null) {
      _showSnack('Seleccione una fecha');
      return;
    }
    if (_horaSeleccionada == null) {
      _showSnack('Seleccione una hora disponible');
      return;
    }
    // TODO: AgendaController.crearCita(...) → POST /api/citas
    _showSnack('Cita guardada exitosamente', error: false);
    Navigator.pop(context);
  }

  void _showSnack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }
}
