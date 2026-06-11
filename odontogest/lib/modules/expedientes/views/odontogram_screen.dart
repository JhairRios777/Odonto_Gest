import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

enum ToothStatus {
  healthy,
  cavity,
  extraction,
  crown,
  filling,
  missing,
  implant,
  fracture,
}

class OdontogramScreen extends StatefulWidget {
  const OdontogramScreen({Key? key}) : super(key: key);

  @override
  State<OdontogramScreen> createState() => _OdontogramScreenState();
}

class _OdontogramScreenState extends State<OdontogramScreen> {
  final Map<int, ToothStatus> _toothStates = {};
  ToothStatus _selectedStatus = ToothStatus.healthy;
  int? _selectedTooth;

  final List<int> _upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
  final List<int> _upperLeft  = [21, 22, 23, 24, 25, 26, 27, 28];
  final List<int> _lowerLeft  = [31, 32, 33, 34, 35, 36, 37, 38];
  final List<int> _lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];

  static const Map<ToothStatus, Color> _statusColors = {
    ToothStatus.healthy:   Color(0xFF4CAF50),
    ToothStatus.cavity:    Color(0xFFE53935),
    ToothStatus.extraction:Color(0xFF212121),
    ToothStatus.crown:     Color(0xFFFFD600),
    ToothStatus.filling:   Color(0xFF1565C0),
    ToothStatus.missing:   Color(0xFF9E9E9E),
    ToothStatus.implant:   Color(0xFF7B1FA2),
    ToothStatus.fracture:  Color(0xFFFF6F00),
  };

  static const Map<ToothStatus, String> _statusLabels = {
    ToothStatus.healthy:   'Sano',
    ToothStatus.cavity:    'Caries',
    ToothStatus.extraction:'Extracción',
    ToothStatus.crown:     'Corona',
    ToothStatus.filling:   'Obturación',
    ToothStatus.missing:   'Ausente',
    ToothStatus.implant:   'Implante',
    ToothStatus.fracture:  'Fractura',
  };

  static const Map<ToothStatus, IconData> _statusIcons = {
    ToothStatus.healthy:   Icons.check_circle_outline,
    ToothStatus.cavity:    Icons.warning_amber_outlined,
    ToothStatus.extraction:Icons.close,
    ToothStatus.crown:     Icons.workspace_premium_outlined,
    ToothStatus.filling:   Icons.square_outlined,
    ToothStatus.missing:   Icons.remove_circle_outline,
    ToothStatus.implant:   Icons.anchor_outlined,
    ToothStatus.fracture:  Icons.bolt_outlined,
  };

  // ─── Helpers ────────────────────────────────────────────────────────────────
  void _onToothTap(int n) =>
      setState(() { _selectedTooth = n; _toothStates[n] = _selectedStatus; });

  void _clearAll() =>
      setState(() { _toothStates.clear(); _selectedTooth = null; });

  Color _toothColor(int n) {
    final s = _toothStates[n];
    return s == null ? const Color(0xFFFFF9C4) : _statusColors[s]!.withAlpha(217);
  }

  bool _isExtracted(int n) =>
      _toothStates[n] == ToothStatus.extraction ||
      _toothStates[n] == ToothStatus.missing;

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2,'0')}/'
           '${now.month.toString().padLeft(2,'0')}/'
           '${now.year}';
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Odontograma',
            style: AppTypography.titleSmall(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Limpiar todo',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPatientHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  _buildStatusSelector(),
                  const SizedBox(height: 12),
                  _buildDentalChart(),
                  const SizedBox(height: 12),
                  _buildLegend(),
                  const SizedBox(height: 12),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Patient Header ─────────────────────────────────────────────────────────
  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0662DB), AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paciente: Juan García',
                  style: AppTypography.bodyMedium(color: Colors.white)),
              Text('Fecha: ${_formattedDate()}',
                  style: AppTypography.caption(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('FDI',
                style: AppTypography.label(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Status Selector ────────────────────────────────────────────────────────
  Widget _buildStatusSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado a aplicar:',
              style: AppTypography.label(color: AppColors.primary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: ToothStatus.values.map((s) {
              final sel = _selectedStatus == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatus = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? _statusColors[s]! : _statusColors[s]!.withAlpha(31),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColors[s]!, width: sel ? 2 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcons[s], size: 13,
                          color: sel ? Colors.white : _statusColors[s]),
                      const SizedBox(width: 4),
                      Text(_statusLabels[s]!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : _statusColors[s],
                            fontFamily: 'Inter',
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Dental Chart ───────────────────────────────────────────────────────────
  Widget _buildDentalChart() {
    return _card(
      child: Column(
        children: [
          _quadrantLabel('SUPERIOR'),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toothRow(_upperRight, isUpper: true),
              _midline(),
              _toothRow(_upperLeft, isUpper: true),
            ],
          ),
          const SizedBox(height: 4),
          _jawDivider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toothRow(_lowerRight, isUpper: false),
              _midline(),
              _toothRow(_lowerLeft, isUpper: false),
            ],
          ),
          const SizedBox(height: 6),
          _quadrantLabel('INFERIOR'),
        ],
      ),
    );
  }

  Widget _quadrantLabel(String label) => Row(children: [
        Expanded(child: Divider(color: Colors.blueGrey.shade100, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(label,
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: const Color(0xFF3B5FBD),
                letterSpacing: 1.2, fontFamily: 'Inter',
              )),
        ),
        Expanded(child: Divider(color: Colors.blueGrey.shade100, thickness: 1)),
      ]);

  Widget _midline() => Container(
        width: 2, height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF3B5FBD).withAlpha(102),
          borderRadius: BorderRadius.circular(1),
        ),
      );

  Widget _jawDivider() => Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            const Color(0xFF3B5FBD).withAlpha(77),
            Colors.transparent,
          ]),
        ),
      );

  Widget _toothRow(List<int> teeth, {required bool isUpper}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: teeth.map((t) => _toothWidget(t, isUpper: isUpper)).toList(),
      );

  Widget _toothWidget(int number, {required bool isUpper}) {
    final isSelected = _selectedTooth == number;
    final extracted  = _isExtracted(number);
    final color      = _toothColor(number);
    final status     = _toothStates[number];

    return GestureDetector(
      onTap: () => _onToothTap(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isUpper
              ? [_toothNum(number), const SizedBox(height: 2),
                 _toothShape(color, isSelected, extracted, status, isUpper)]
              : [_toothShape(color, isSelected, extracted, status, isUpper),
                 const SizedBox(height: 2), _toothNum(number)],
        ),
      ),
    );
  }

  Widget _toothNum(int n) => Text('$n',
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 8, fontWeight: FontWeight.w600,
          color: AppColors.primary, fontFamily: 'Inter'));

  Widget _toothShape(Color color, bool isSelected, bool extracted,
      ToothStatus? status, bool isUpper) {
    return Container(
      width: 30, height: 38,
      decoration: BoxDecoration(
        color: extracted ? Colors.transparent : color,
        borderRadius: BorderRadius.only(
          topLeft:     Radius.circular(isUpper ? 10 : 4),
          topRight:    Radius.circular(isUpper ? 10 : 4),
          bottomLeft:  Radius.circular(isUpper ? 4 : 10),
          bottomRight: Radius.circular(isUpper ? 4 : 10),
        ),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF1565C0)
              : extracted
                  ? Colors.grey.shade400
                  : color.withAlpha(153),
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(
                color: const Color(0xFF1565C0).withAlpha(102),
                blurRadius: 6, spreadRadius: 1)]
            : [],
      ),
      child: extracted
          ? Center(child: Icon(Icons.close, size: 16, color: Colors.grey.shade500))
          : status != null
              ? Center(child: Icon(_statusIcons[status], size: 14, color: Colors.white))
              : null,
    );
  }

  // ─── Legend ─────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leyenda',
              style: AppTypography.label(color: AppColors.primary)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4.5,
            mainAxisSpacing: 4, crossAxisSpacing: 4,
            children: ToothStatus.values.map((s) => Row(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: _statusColors[s],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(_statusIcons[s], size: 10, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_statusLabels[s]!,
                      style: AppTypography.caption(color: AppColors.textDark),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Summary ────────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    if (_toothStates.isEmpty) return const SizedBox.shrink();
    final grouped = <ToothStatus, List<int>>{};
    _toothStates.forEach((t, s) => grouped.putIfAbsent(s, () => []).add(t));

    return _card(
      border: Border.all(color: const Color(0xFF3B5FBD).withAlpha(77)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_outlined,
                  color: Color(0xFF3B5FBD), size: 16),
              const SizedBox(width: 6),
              Text('Resumen del Odontograma',
                  style: AppTypography.label(color: AppColors.primary)),
              const Spacer(),
              Text('${_toothStates.length} dientes',
                  style: AppTypography.caption(
                      color: const Color(0xFF3B5FBD))),
            ],
          ),
          const SizedBox(height: 8),
          ...grouped.entries.map((e) {
            final sorted = List<int>.from(e.value)..sort();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10, height: 10,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _statusColors[e.key], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('${_statusLabels[e.key]}: ',
                      style: AppTypography.caption(color: AppColors.textDark)
                          .copyWith(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Text(sorted.join(', '),
                        style: AppTypography.caption(color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Shared card wrapper ─────────────────────────────────────────────────────
  Widget _card({required Widget child, BoxBorder? border}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
