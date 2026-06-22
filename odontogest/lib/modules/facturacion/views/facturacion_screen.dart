// FacturacionScreen — listado de facturas y pagos.
// TODO: Implementar con filtros por estado, ISV (0%/15%/18%), totales en L.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class FacturacionScreen extends StatelessWidget {
  const FacturacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Facturación'),
      body: const Center(
        child: Text('Facturación — próximamente'),
      ),
    );
  }
}
