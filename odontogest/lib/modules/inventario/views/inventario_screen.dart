// InventarioScreen — gestión de materiales e insumos dentales.
// TODO: Implementar con alertas de stock mínimo, entradas/salidas.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Inventario'),
      body: const Center(
        child: Text('Inventario — próximamente'),
      ),
    );
  }
}
