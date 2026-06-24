<?php
$q        = trim($_GET['q'] ?? '');
$estado   = $_GET['estado'] ?? '';
$page     = (int)($_GET['page'] ?? 1);
$pacientes = $pacientes ?? [];
$total    = $total    ?? 0;
$totalPag = $totalPag ?? 1;

$kpis = $kpis ?? ['total'=>0,'activos'=>0,'nuevos_mes'=>0,'con_cita'=>0];
?>
<div style="padding:24px 28px;">

    <!-- KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon blue"><i class="fas fa-users"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['total'] ?? 0)) ?></div>
                <div class="kpi-label">Total pacientes</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon green"><i class="fas fa-user-check"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['activos'] ?? 0)) ?></div>
                <div class="kpi-label">Activos</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon amber"><i class="fas fa-user-plus"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['nuevos_mes'] ?? 0)) ?></div>
                <div class="kpi-label">Nuevos este mes</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon cyan"><i class="fas fa-calendar-check"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['con_cita'] ?? 0)) ?></div>
                <div class="kpi-label">Con cita pendiente</div>
            </div>
        </div>
    </div>

    <!-- Barra de búsqueda -->
    <div class="kpi-card" style="padding:14px 18px;margin-bottom:16px;">
        <form method="GET" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:space-between;">
            <div style="display:flex;gap:10px;flex:1;flex-wrap:wrap;">
                <div style="position:relative;flex:1;min-width:200px;">
                    <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:.82rem;"></i>
                    <input type="text" name="q" value="<?= htmlspecialchars($q) ?>"
                           placeholder="Buscar por nombre, DNI o teléfono..."
                           class="form-control" style="padding-left:34px;">
                </div>
                <select name="estado" class="form-select" style="max-width:140px;">
                    <option value="">Todos</option>
                    <option value="activo"   <?= $estado==='activo'   ? 'selected':'' ?>>Activos</option>
                    <option value="inactivo" <?= $estado==='inactivo' ? 'selected':'' ?>>Inactivos</option>
                </select>
                <button type="submit" class="btn-og-primary" style="padding:8px 16px;">
                    <i class="fas fa-search me-1"></i>Buscar
                </button>
                <?php if ($q || $estado): ?>
                <a href="?" class="btn btn-sm" style="color:#6B7280;border:1px solid #DDE4EF;border-radius:8px;padding:7px 14px;background:#fff;">
                    <i class="fas fa-times me-1"></i>Limpiar
                </a>
                <?php endif; ?>
            </div>
            <a href="<?= APP_URL ?>Pacientes/nuevo" class="btn-og-primary">
                <i class="fas fa-user-plus"></i> Nuevo Paciente
            </a>
        </form>
    </div>

    <!-- Tabla -->
    <div class="kpi-card" style="padding:0;">
        <div style="overflow-x:auto;">
            <table class="tabla-og">
                <thead>
                    <tr>
                        <th>Paciente</th>
                        <th>DNI</th>
                        <th>Teléfono</th>
                        <th>Correo</th>
                        <th>Fecha reg.</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <?php if (empty($pacientes)): ?>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="fas fa-user-slash fa-2x mb-2 d-block" style="opacity:.25;"></i>
                            No se encontraron pacientes
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($pacientes as $p):
                        $initials = '';
                        foreach (array_slice(explode(' ', $p['nombre_completo'] ?? 'X'), 0, 2) as $pt) {
                            $initials .= strtoupper(mb_substr($pt, 0, 1));
                        }
                    ?>
                    <tr>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <div style="width:34px;height:34px;border-radius:50%;background:#EEF3FC;
                                            display:flex;align-items:center;justify-content:center;
                                            font-size:.78rem;font-weight:700;color:#1A56AB;flex-shrink:0;">
                                    <?= htmlspecialchars($initials) ?>
                                </div>
                                <div>
                                    <div style="font-weight:600;color:#1A2940;"><?= htmlspecialchars($p['nombre_completo'] ?? '—') ?></div>
                                    <?php if (!empty($p['genero'])): ?>
                                    <div style="font-size:.73rem;color:#9CA3AF;"><?= htmlspecialchars(ucfirst($p['genero'])) ?></div>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </td>
                        <td style="color:#6B7280;font-size:.84rem;"><?= htmlspecialchars($p['dni'] ?? '—') ?></td>
                        <td style="color:#6B7280;font-size:.84rem;"><?= htmlspecialchars($p['telefono'] ?? '—') ?></td>
                        <td style="color:#6B7280;font-size:.84rem;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                            <?= htmlspecialchars($p['correo'] ?? '—') ?>
                        </td>
                        <td style="font-size:.8rem;color:#9CA3AF;"><?= htmlspecialchars($p['fecha_registro'] ?? '') ?></td>
                        <td>
                            <span class="badge-og badge-<?= strtolower($p['estado'] ?? 'inactivo') ?>">
                                <?= ucfirst($p['estado'] ?? '') ?>
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;">
                                <a href="<?= APP_URL ?>Expedientes/paciente/<?= $p['id_paciente'] ?>"
                                   class="btn btn-sm" title="Ver expediente"
                                   style="background:#EEF3FC;color:#1A56AB;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-folder-open"></i>
                                </a>
                                <a href="<?= APP_URL ?>Pacientes/editar/<?= $p['id_paciente'] ?>"
                                   class="btn btn-sm" title="Editar"
                                   style="background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="<?= APP_URL ?>Agenda/nueva?id_paciente=<?= $p['id_paciente'] ?>"
                                   class="btn btn-sm" title="Agendar cita"
                                   style="background:rgba(22,163,74,.08);color:#16a34a;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-calendar-plus"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
                </tbody>
            </table>
        </div>

        <?php if ($totalPag > 1): ?>
        <div style="padding:14px 18px;border-top:1px solid #DDE4EF;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
            <span style="font-size:.8rem;color:#6B7280;"><?= $total ?> pacientes — Página <?= $page ?> de <?= $totalPag ?></span>
            <div style="display:flex;gap:4px;">
                <?php for ($i = max(1,$page-2); $i <= min($totalPag,$page+2); $i++): ?>
                <a href="?<?= http_build_query(array_merge($_GET,['page'=>$i])) ?>"
                   style="width:32px;height:32px;display:flex;align-items:center;justify-content:center;
                          border-radius:7px;font-size:.82rem;font-weight:600;text-decoration:none;
                          <?= $i===$page ? 'background:#1A56AB;color:#fff;' : 'background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;' ?>">
                    <?= $i ?>
                </a>
                <?php endfor; ?>
            </div>
        </div>
        <?php endif; ?>
    </div>

</div>
