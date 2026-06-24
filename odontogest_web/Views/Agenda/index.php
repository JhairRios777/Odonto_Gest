<?php
// Variables esperadas del AgendaController:
// $citas    → array de citas filtradas
// $filtro   → string del estado activo
// $total    → int total resultados
// $page     → int página actual
// $totalPag → int total páginas
$filtro   = $_GET['estado'] ?? 'todas';
$q        = trim($_GET['q'] ?? '');
$citas    = $citas    ?? [];
$total    = $total    ?? 0;
$page     = $page     ?? 1;
$totalPag = $totalPag ?? 1;

$estadoBadge = [
    'pendiente'  => 'badge-pendiente',
    'confirmada' => 'badge-confirmada',
    'atendida'   => 'badge-atendida',
    'cancelada'  => 'badge-cancelada',
    'en_curso'   => 'badge-en_curso',
];
$tabs = [
    'todas'      => 'Todas',
    'pendiente'  => 'Pendientes',
    'atendida'   => 'Atendidas',
    'cancelada'  => 'Canceladas',
    'confirmada' => 'Confirmadas',
];
?>
<div style="padding:24px 28px;">

    <!-- Encabezado -->
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px;flex-wrap:wrap;gap:12px;">
        <div>
            <h4 style="font-size:1.1rem;font-weight:700;color:#1A2940;margin:0;">Agenda de Citas</h4>
            <div style="font-size:.78rem;color:#6B7280;margin-top:2px;"><?= $total ?> citas encontradas</div>
        </div>
        <a href="<?= APP_URL ?>Agenda/nuevo" class="btn-og-primary">
            <i class="fas fa-plus"></i> Nueva Cita
        </a>
    </div>

    <!-- Tabs de estado -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px;">
        <?php foreach ($tabs as $val => $lbl): ?>
        <a href="?estado=<?= $val ?><?= $q ? '&q='.urlencode($q) : '' ?>"
           class="filter-tab <?= $filtro === $val ? 'active' : '' ?>">
            <?= $lbl ?>
        </a>
        <?php endforeach; ?>
    </div>

    <!-- Buscador + filtros -->
    <div class="kpi-card" style="padding:14px 18px;margin-bottom:16px;">
        <form method="GET" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
            <input type="hidden" name="estado" value="<?= htmlspecialchars($filtro) ?>">
            <div style="position:relative;flex:1;min-width:200px;">
                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:.82rem;"></i>
                <input type="text" name="q" value="<?= htmlspecialchars($q) ?>"
                       placeholder="Buscar paciente u odontólogo..."
                       class="form-control" style="padding-left:34px;border-radius:8px;">
            </div>
            <input type="date" name="fecha" value="<?= htmlspecialchars($_GET['fecha'] ?? '') ?>"
                   class="form-control" style="max-width:160px;">
            <button type="submit" class="btn-og-primary" style="padding:8px 16px;">
                <i class="fas fa-search me-1"></i>Filtrar
            </button>
            <?php if ($q || isset($_GET['fecha'])): ?>
            <a href="?estado=<?= $filtro ?>" class="btn btn-sm" style="color:#6B7280;border:1px solid #DDE4EF;border-radius:8px;padding:7px 14px;background:#fff;">
                <i class="fas fa-times me-1"></i>Limpiar
            </a>
            <?php endif; ?>
        </form>
    </div>

    <!-- Tabla -->
    <div class="kpi-card" style="padding:0;">
        <div style="overflow-x:auto;">
            <table class="tabla-og">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Fecha & Hora</th>
                        <th>Paciente</th>
                        <th>Odontólogo</th>
                        <th>Servicio</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <?php if (empty($citas)): ?>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="fas fa-calendar-times fa-2x mb-2 d-block" style="opacity:.25;"></i>
                            No hay citas que coincidan con los filtros
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($citas as $c): ?>
                    <tr>
                        <td style="color:#9CA3AF;font-size:.8rem;">#<?= $c['id_cita'] ?></td>
                        <td>
                            <div style="font-weight:600;color:#1A2940;"><?= htmlspecialchars($c['fecha'] ?? '') ?></div>
                            <div style="font-size:.78rem;color:#1A56AB;font-weight:600;"><?= htmlspecialchars(substr($c['hora'] ?? '', 0, 5)) ?></div>
                        </td>
                        <td style="font-weight:500;"><?= htmlspecialchars($c['paciente'] ?? '—') ?></td>
                        <td style="color:#6B7280;font-size:.84rem;"><?= htmlspecialchars($c['odontologo'] ?? '—') ?></td>
                        <td style="color:#6B7280;font-size:.84rem;"><?= htmlspecialchars($c['servicio'] ?? '—') ?></td>
                        <td>
                            <?php $est = strtolower($c['estado'] ?? ''); ?>
                            <span class="badge-og <?= $estadoBadge[$est] ?? 'badge-inactivo' ?>">
                                <?= htmlspecialchars(ucfirst($est)) ?>
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;">
                                <a href="<?= APP_URL ?>Agenda/editar/<?= $c['id_cita'] ?>"
                                   class="btn btn-sm" style="background:#EEF3FC;color:#1A56AB;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <button class="btn btn-sm" onclick="eliminarCita(<?= $c['id_cita'] ?>)"
                                        style="background:rgba(220,38,38,.08);color:#dc2626;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-trash"></i>
                                </button>
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
            <span style="font-size:.8rem;color:#6B7280;">Página <?= $page ?> de <?= $totalPag ?></span>
            <div style="display:flex;gap:4px;">
                <?php for ($i = max(1, $page-2); $i <= min($totalPag, $page+2); $i++): ?>
                <a href="?<?= http_build_query(array_merge($_GET, ['page'=>$i])) ?>"
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

<script>
function eliminarCita(id){
    Swal.fire({
        title:'¿Eliminar cita?',
        text:'Esta acción no se puede deshacer.',
        icon:'warning',
        showCancelButton:true,
        confirmButtonColor:'#dc2626',
        cancelButtonColor:'#6b7280',
        confirmButtonText:'Sí, eliminar',
        cancelButtonText:'Cancelar'
    }).then(r=>{
        if(!r.isConfirmed)return;
        fetch('<?= APP_URL ?>Agenda/delete',{
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body:JSON.stringify({id_cita:id,_csrf:'<?= htmlspecialchars(Csrf::token()) ?>'})
        }).then(r=>r.json()).then(d=>{
            if(d.success) location.reload();
            else Swal.fire('Error',d.error||'No se pudo eliminar','error');
        });
    });
}
</script>
