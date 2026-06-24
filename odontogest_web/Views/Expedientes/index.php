<?php
// Vista: Expediente del paciente
// Variables esperadas:
// $paciente   → datos del paciente
// $historial  → array de entradas del historial
// $facturas   → array de facturas del paciente
// $tab        → tab activo ('historial'|'odontograma'|'facturas'|'documentos')

$tab      = $_GET['tab'] ?? 'historial';
$paciente = $paciente ?? [];
$historial= $historial ?? [];
$facturas = $facturas  ?? [];

$tabs = [
    'historial'   => ['ico'=>'fas fa-notes-medical',   'lbl'=>'Historial Clínico'],
    'odontograma' => ['ico'=>'fas fa-tooth',            'lbl'=>'Odontograma'],
    'facturas'    => ['ico'=>'fas fa-file-invoice-dollar','lbl'=>'Facturas'],
    'documentos'  => ['ico'=>'fas fa-file-medical',    'lbl'=>'Documentos'],
];
$nombre = htmlspecialchars($paciente['nombre_completo'] ?? 'Paciente');
$initials = '';
foreach (array_slice(explode(' ', $paciente['nombre_completo'] ?? 'X'), 0, 2) as $pt) {
    $initials .= strtoupper(mb_substr($pt, 0, 1));
}
?>
<div style="padding:24px 28px;">

    <!-- Breadcrumb -->
    <nav style="font-size:.8rem;color:#6B7280;margin-bottom:16px;">
        <a href="<?= APP_URL ?>Pacientes/index" style="color:#1A56AB;text-decoration:none;">Pacientes</a>
        <i class="fas fa-chevron-right mx-1" style="font-size:.65rem;"></i>
        <span><?= $nombre ?></span>
        <i class="fas fa-chevron-right mx-1" style="font-size:.65rem;"></i>
        <span>Expediente</span>
    </nav>

    <!-- Cabecera del paciente -->
    <div class="kpi-card" style="margin-bottom:20px;">
        <div style="display:flex;align-items:center;gap:18px;flex-wrap:wrap;">
            <!-- Avatar -->
            <div style="width:64px;height:64px;border-radius:50%;background:#EEF3FC;
                        display:flex;align-items:center;justify-content:center;
                        font-size:1.4rem;font-weight:800;color:#1A56AB;flex-shrink:0;border:3px solid #DDE4EF;">
                <?= htmlspecialchars($initials) ?>
            </div>
            <!-- Info principal -->
            <div style="flex:1;min-width:0;">
                <h5 style="font-size:1.15rem;font-weight:800;color:#1A2940;margin:0 0 4px;"><?= $nombre ?></h5>
                <div style="display:flex;gap:16px;flex-wrap:wrap;">
                    <?php if (!empty($paciente['dni'])): ?>
                    <span style="font-size:.8rem;color:#6B7280;"><i class="fas fa-id-card me-1"></i><?= htmlspecialchars($paciente['dni']) ?></span>
                    <?php endif; ?>
                    <?php if (!empty($paciente['telefono'])): ?>
                    <span style="font-size:.8rem;color:#6B7280;"><i class="fas fa-phone me-1"></i><?= htmlspecialchars($paciente['telefono']) ?></span>
                    <?php endif; ?>
                    <?php if (!empty($paciente['correo'])): ?>
                    <span style="font-size:.8rem;color:#6B7280;"><i class="fas fa-envelope me-1"></i><?= htmlspecialchars($paciente['correo']) ?></span>
                    <?php endif; ?>
                    <?php if (!empty($paciente['fecha_nacimiento'])): ?>
                    <span style="font-size:.8rem;color:#6B7280;">
                        <i class="fas fa-birthday-cake me-1"></i>
                        <?= htmlspecialchars($paciente['fecha_nacimiento']) ?>
                        (<?= (new DateTime($paciente['fecha_nacimiento']))->diff(new DateTime())->y ?> años)
                    </span>
                    <?php endif; ?>
                </div>
            </div>
            <!-- Acciones -->
            <div style="display:flex;gap:8px;flex-shrink:0;">
                <a href="<?= APP_URL ?>Agenda/nueva?id_paciente=<?= $paciente['id_paciente'] ?? '' ?>"
                   class="btn-og-primary" style="font-size:.8rem;padding:7px 14px;">
                    <i class="fas fa-calendar-plus me-1"></i>Nueva Cita
                </a>
                <a href="<?= APP_URL ?>Pacientes/editar/<?= $paciente['id_paciente'] ?? '' ?>"
                   style="padding:7px 14px;border-radius:8px;font-size:.8rem;font-weight:600;
                          border:1px solid #DDE4EF;background:#fff;color:#374151;text-decoration:none;
                          display:inline-flex;align-items:center;gap:6px;">
                    <i class="fas fa-edit"></i>Editar
                </a>
            </div>
        </div>
    </div>

    <!-- Tabs -->
    <div style="display:flex;gap:2px;border-bottom:2px solid #DDE4EF;margin-bottom:20px;overflow-x:auto;">
        <?php foreach ($tabs as $key => $t): ?>
        <a href="?id=<?= $paciente['id_paciente'] ?? '' ?>&tab=<?= $key ?>"
           style="padding:10px 18px;font-size:.87rem;font-weight:600;text-decoration:none;white-space:nowrap;
                  color:<?= $tab===$key ? '#1A56AB' : '#6B7280' ?>;
                  border-bottom:<?= $tab===$key ? '2px solid #1A56AB' : '2px solid transparent' ?>;
                  margin-bottom:-2px;transition:color .15s;">
            <i class="<?= $t['ico'] ?> me-1"></i><?= $t['lbl'] ?>
        </a>
        <?php endforeach; ?>
    </div>

    <!-- Contenido por tab -->
    <?php if ($tab === 'historial'): ?>
    <div class="row g-3">
        <div class="col-12 col-lg-8">
            <div class="kpi-card" style="padding:0;">
                <div style="padding:14px 20px;border-bottom:1px solid #DDE4EF;display:flex;justify-content:space-between;align-items:center;">
                    <span style="font-size:.9rem;font-weight:700;color:#1A2940;">Historial Clínico</span>
                    <a href="<?= APP_URL ?>Expedientes/nueva-entrada?id=<?= $paciente['id_paciente'] ?? '' ?>"
                       class="btn-og-primary" style="font-size:.78rem;padding:6px 14px;">
                        <i class="fas fa-plus me-1"></i>Nueva Entrada
                    </a>
                </div>
                <?php if (empty($historial)): ?>
                <div class="text-center py-5 text-muted" style="font-size:.85rem;">
                    <i class="fas fa-notes-medical fa-2x mb-2 d-block" style="opacity:.25;"></i>
                    Sin entradas en el historial
                </div>
                <?php else: ?>
                <div style="padding:4px 0;">
                    <?php foreach ($historial as $h): ?>
                    <div style="padding:16px 20px;border-bottom:1px solid #F0F3F8;">
                        <div style="display:flex;justify-content:space-between;margin-bottom:8px;flex-wrap:wrap;gap:8px;">
                            <div>
                                <span style="font-size:.8rem;font-weight:700;color:#1A56AB;">
                                    <?= htmlspecialchars($h['tipo_consulta'] ?? 'Consulta') ?>
                                </span>
                                <span style="font-size:.76rem;color:#9CA3AF;margin-left:8px;">
                                    <i class="fas fa-user me-1"></i><?= htmlspecialchars($h['odontologo'] ?? '') ?>
                                </span>
                            </div>
                            <span style="font-size:.76rem;color:#9CA3AF;">
                                <i class="fas fa-clock me-1"></i><?= htmlspecialchars($h['fecha'] ?? '') ?>
                            </span>
                        </div>
                        <?php if (!empty($h['motivo'])): ?>
                        <div style="font-size:.83rem;color:#1A2940;margin-bottom:6px;">
                            <strong style="color:#374151;">Motivo:</strong> <?= htmlspecialchars($h['motivo']) ?>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($h['diagnostico'])): ?>
                        <div style="font-size:.83rem;color:#1A2940;margin-bottom:6px;">
                            <strong style="color:#374151;">Diagnóstico:</strong> <?= htmlspecialchars($h['diagnostico']) ?>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($h['tratamiento'])): ?>
                        <div style="font-size:.83rem;color:#1A2940;">
                            <strong style="color:#374151;">Tratamiento:</strong> <?= htmlspecialchars($h['tratamiento']) ?>
                        </div>
                        <?php endif; ?>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
        <!-- Sidebar info médica -->
        <div class="col-12 col-lg-4">
            <div class="kpi-card">
                <div style="font-size:.88rem;font-weight:700;color:#1A2940;margin-bottom:14px;">
                    <i class="fas fa-heartbeat me-1" style="color:#dc2626;"></i>Info Médica
                </div>
                <?php $campos = [
                    'alergias'          => ['Alergias',        'fas fa-allergies',   '#dc2626'],
                    'enfermedades'      => ['Enfermedades',    'fas fa-virus',       '#d97706'],
                    'medicamentos'      => ['Medicamentos',    'fas fa-pills',       '#9333ea'],
                    'grupo_sanguineo'   => ['Grupo sanguíneo', 'fas fa-tint',        '#1A56AB'],
                ]; ?>
                <?php foreach ($campos as $key => [$lbl, $ico, $color]): ?>
                <div style="margin-bottom:12px;padding:10px 12px;background:#F5F7FB;border-radius:8px;">
                    <div style="font-size:.74rem;font-weight:600;color:<?= $color ?>;margin-bottom:3px;">
                        <i class="<?= $ico ?> me-1"></i><?= $lbl ?>
                    </div>
                    <div style="font-size:.82rem;color:#374151;">
                        <?= htmlspecialchars(!empty($paciente[$key]) ? $paciente[$key] : 'No especificado') ?>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>

    <?php elseif ($tab === 'odontograma'): ?>
    <div class="kpi-card" style="padding:24px;">
        <div style="font-size:.9rem;font-weight:700;color:#1A2940;margin-bottom:16px;">
            <i class="fas fa-tooth me-1" style="color:#1A56AB;"></i>Odontograma
        </div>
        <!-- Odontograma SVG simplificado (adulto: 32 piezas) -->
        <div style="overflow-x:auto;text-align:center;">
            <p class="text-muted" style="font-size:.85rem;">
                <i class="fas fa-info-circle me-1"></i>
                El odontograma interactivo se gestiona desde la aplicación móvil.<br>
                Los datos registrados se muestran en el mapa dental a continuación.
            </p>
            <?php
            $piezas = [18,17,16,15,14,13,12,11,21,22,23,24,25,26,27,28,
                       48,47,46,45,44,43,42,41,31,32,33,34,35,36,37,38];
            $condiciones = $condiciones ?? [];
            $colorCond   = [
                'caries'      => '#dc2626',
                'corona'      => '#d97706',
                'ausente'     => '#9CA3AF',
                'implante'    => '#1A56AB',
                'obturacion'  => '#16a34a',
                'sano'        => '#F0F3F8',
            ];
            ?>
            <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px;max-width:600px;margin:0 auto;">
                <?php foreach ($piezas as $num):
                    $cond  = $condiciones[$num]['condicion'] ?? 'sano';
                    $color = $colorCond[$cond] ?? '#F0F3F8';
                    $border= in_array($cond,['sano']) ? '#DDE4EF' : $color;
                    $title = ucfirst($cond);
                ?>
                <div style="width:40px;height:46px;border:2px solid <?= $border ?>;background:<?= $color ?>;
                            border-radius:8px;display:flex;flex-direction:column;align-items:center;
                            justify-content:center;cursor:pointer;transition:transform .15s;"
                     title="Pieza <?= $num ?> — <?= $title ?>"
                     onmouseenter="this.style.transform='scale(1.15)'"
                     onmouseleave="this.style.transform='scale(1)'">
                    <div style="font-size:.72rem;font-weight:700;color:<?= in_array($cond,['sano']) ? '#9CA3AF' : '#fff' ?>;">
                        <?= $num ?>
                    </div>
                    <i class="fas fa-tooth" style="font-size:.55rem;color:<?= in_array($cond,['sano']) ? '#DDE4EF' : 'rgba(255,255,255,.7)' ?>;margin-top:2px;"></i>
                </div>
                <?php if ($num === 28): ?>
                </div><div style="font-size:.72rem;color:#9CA3AF;margin:4px 0;width:100%;text-align:center;">— Mandíbula —</div>
                <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px;max-width:600px;margin:0 auto;">
                <?php endif; ?>
                <?php endforeach; ?>
            </div>
            <!-- Leyenda -->
            <div style="display:flex;gap:12px;flex-wrap:wrap;justify-content:center;margin-top:16px;">
                <?php foreach ($colorCond as $k => $c): ?>
                <div style="display:flex;align-items:center;gap:5px;font-size:.75rem;color:#374151;">
                    <div style="width:14px;height:14px;border-radius:3px;background:<?= $c ?>;border:1px solid <?= $k==='sano'?'#DDE4EF':$c ?>;"></div>
                    <?= ucfirst($k) ?>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>

    <?php elseif ($tab === 'facturas'): ?>
    <div class="kpi-card" style="padding:0;">
        <div style="padding:14px 20px;border-bottom:1px solid #DDE4EF;">
            <span style="font-size:.9rem;font-weight:700;color:#1A2940;">Facturas del Paciente</span>
        </div>
        <div style="overflow-x:auto;">
            <table class="tabla-og">
                <thead>
                    <tr><th># Factura</th><th>Fecha</th><th>Subtotal</th><th>ISV</th><th>Total</th><th>Estado</th><th></th></tr>
                </thead>
                <tbody>
                <?php if (empty($facturas)): ?>
                    <tr><td colspan="7" class="text-center py-4 text-muted">Sin facturas registradas</td></tr>
                <?php else: ?>
                    <?php foreach ($facturas as $f): ?>
                    <tr>
                        <td style="font-weight:700;color:#1A56AB;">#<?= str_pad($f['id_factura'], 5, '0', STR_PAD_LEFT) ?></td>
                        <td style="font-size:.83rem;color:#6B7280;"><?= htmlspecialchars($f['fecha'] ?? '') ?></td>
                        <td>L <?= number_format((float)($f['subtotal'] ?? 0), 2) ?></td>
                        <td style="color:#6B7280;">L <?= number_format((float)($f['isv'] ?? 0), 2) ?></td>
                        <td style="font-weight:700;">L <?= number_format((float)($f['total'] ?? 0), 2) ?></td>
                        <td>
                            <span class="badge-og badge-<?= strtolower($f['estado'] ?? '') ?>">
                                <?= ucfirst($f['estado'] ?? '') ?>
                            </span>
                        </td>
                        <td>
                            <a href="<?= APP_URL ?>Facturacion/ver/<?= $f['id_factura'] ?>"
                               style="background:#EEF3FC;color:#1A56AB;border:none;border-radius:6px;padding:5px 9px;font-size:.78rem;display:inline-block;">
                                <i class="fas fa-eye"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <?php elseif ($tab === 'documentos'): ?>
    <div class="kpi-card">
        <div style="font-size:.9rem;font-weight:700;color:#1A2940;margin-bottom:16px;">
            <i class="fas fa-file-medical me-1" style="color:#1A56AB;"></i>Documentos y Radiografías
        </div>
        <?php $docs = $documentos ?? []; ?>
        <?php if (empty($docs)): ?>
        <div class="text-center py-5 text-muted" style="font-size:.85rem;">
            <i class="fas fa-file-medical fa-2x mb-2 d-block" style="opacity:.25;"></i>
            No hay documentos adjuntos
        </div>
        <?php else: ?>
        <div class="row g-3">
            <?php foreach ($docs as $d): ?>
            <div class="col-6 col-md-4 col-xl-3">
                <div style="border:1px solid #DDE4EF;border-radius:10px;overflow:hidden;background:#F5F7FB;">
                    <div style="height:100px;display:flex;align-items:center;justify-content:center;background:#EEF3FC;">
                        <i class="fas fa-file-image" style="font-size:2rem;color:#1A56AB;opacity:.4;"></i>
                    </div>
                    <div style="padding:10px;">
                        <div style="font-size:.8rem;font-weight:600;color:#1A2940;truncate;"><?= htmlspecialchars($d['nombre'] ?? '') ?></div>
                        <div style="font-size:.72rem;color:#9CA3AF;"><?= htmlspecialchars($d['fecha'] ?? '') ?></div>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
        <div style="margin-top:16px;">
            <a href="<?= APP_URL ?>Expedientes/subir?id=<?= $paciente['id_paciente'] ?? '' ?>"
               class="btn-og-primary" style="font-size:.85rem;">
                <i class="fas fa-upload me-1"></i>Subir Documento
            </a>
        </div>
    </div>
    <?php endif; ?>

</div>
