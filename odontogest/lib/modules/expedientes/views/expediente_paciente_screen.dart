// ExpedientePacienteScreen — historial clínico completo del paciente.
// TODO: Implementar con tabs: Datos, Odontograma, Tratamientos, Pagos.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class ExpedientePacienteScreen extends StatelessWidget {
  const ExpedientePacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Expediente Paciente',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Expediente — próximamente'),
      ),
    );
  }
}
