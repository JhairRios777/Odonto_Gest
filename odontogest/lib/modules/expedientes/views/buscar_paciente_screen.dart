// BuscarPacienteScreen — buscador de pacientes para abrir expediente.
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/services/expediente_service.dart';
import 'expediente_paciente_screen.dart';

class BuscarPacienteScreen extends StatefulWidget {
  const BuscarPacienteScreen({super.key});

  @override
  State<BuscarPacienteScreen> createState() => _BuscarPacienteScreenState();
}

class _BuscarPacienteScreenState extends State<BuscarPacienteScreen> {
  final _ctrl      = TextEditingController();
  bool  _loading   = false;
  List<BusquedaPaciente> _resultados = [];
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _buscar(String q) async {
    q = q.trim();
    if (q.length < 2) {
      setState(() { _resultados = []; _error = null; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    final res = await ExpedienteService.buscarPacientes(q);
    if (!mounted) return;
    setState(() {
      _resultados = res;
      _loading    = false;
      _error      = res.isEmpty ? 'No se encontraron pacientes' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Buscar Paciente',
            style: AppTypography.titleSmall(color: Colors.white)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller:    _ctrl,
              autofocus:     true,
              onChanged:     _buscar,
              style:         AppTypography.body(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText:    'Nombre o número de expediente…',
                hintStyle:   AppTypography.body(color: AppColors.textMuted),
                prefixIcon:  const Icon(Icons.search, color: AppColors.primary),
                suffixIcon:  _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() { _resultados = []; _error = null; });
                        })
                    : null,
                filled:      true,
                fillColor:   AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),

          // ── Resultados ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: AppTypography.body(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    : _resultados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_search,
                                    size: 64, color: AppColors.primaryLight),
                                const SizedBox(height: 16),
                                Text('Escribe el nombre del paciente',
                                    style: AppTypography.body(color: AppColors.textMuted)),
                                const SizedBox(height: 4),
                                Text('Mínimo 2 caracteres',
                                    style: AppTypography.caption(color: AppColors.textMuted)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _resultados.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _PacienteCard(
                              paciente: _resultados[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpedientePacienteScreen(
                                    idPaciente: _resultados[i].idPaciente,
                                    nombrePaciente: _resultados[i].nombre,
                                  ),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _PacienteCard extends StatelessWidget {
  const _PacienteCard({required this.paciente, required this.onTap});
  final BusquedaPaciente paciente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  paciente.nombre.isNotEmpty ? paciente.nombre[0].toUpperCase() : 'P',
                  style: AppTypography.titleSmall(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paciente.nombre,
                        style: AppTypography.bodyMedium(color: AppColors.textDark)),
                    if (paciente.numExpediente != null)
                      Text('Exp. ${paciente.numExpediente}',
                          style: AppTypography.caption(color: AppColors.textMuted)),
                    if (paciente.telefono != null)
                      Text(paciente.telefono!,
                          style: AppTypography.captionXs(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
