<?php
$q        = trim($_GET['q'] ?? '');
$estado   = $_GET['estado'] ?? 'todas';
$fechaD   = $_GET['fecha_desde'] ?? '';
$fechaH   = $_GET['fecha_hasta'] ?? '';
$page     = (int)($_GET['page'] ?? 1);
$facturas = $facturas ?? [];
$total    = $total    ?? 0;
$totalPag = $totalPag ?? 1;
$kpis     = $kpis     ?? ['total_dia'=>0,'pendiente'=>0,'pagada'=>0,'anulada'=>0];

$tabs = ['todas'=>'Todas','pendiente'=>'Pendientes','pagada'=>'Pagadas','anulada'=>'Anuladas'];
$fmt  = fn(float $n) => 'L '.number_format($n, 2, '.', ',');
?>
<div style="padding:24px 28px;">

    <!-- KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon blue"><i class="fas fa-file-invoice-dollar"></i></div>
                <div class="kpi-value" style="font-size:1.4rem;"><?= $fmt((float)($kpis['total_dia'] ?? 0)) ?></div>
                <div class="kpi-label">Ingresos hoy</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon amber"><i class="fas fa-clock"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['pendiente'] ?? 0)) ?></div>
                <div class="kpi-label">Pendientes de cobro</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon green"><i class="fas fa-check-circle"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['pagada'] ?? 0)) ?></div>
                <div class="kpi-label">Pagadas este mes</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon red"><i class="fas fa-times-circle"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['anulada'] ?? 0)) ?></div>
                <div class="kpi-label">Anuladas</div>
            </div>
        </div>
    </div>

    <!-- Tabs -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px;">
        <?php foreach ($tabs as $val => $lbl): ?>
        <a href="?estado=<?= $val ?>" class="filter-tab <?= $estado===$val ? 'active' : '' ?>">
            <?= $lbl ?>
        </a>
        <?php endforeach; ?>
    </div>

    <!-- Filtros -->
    <div class="kpi-card" style="padding:14px 18px;margin-bottom:16px;">
        <form method="GET" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:space-between;">
            <input type="hidden" name="estado" value="<?= htmlspecialchars($estado) ?>">
            <div style="display:flex;gap:10px;flex:1;flex-wrap:wrap;">
                <div style="position:relative;flex:1;min-width:200px;">
                    <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:.82rem;"></i>
                    <input type="text" name="q" value="<?= htmlspecialchars($q) ?>"
                           placeholder="Buscar por paciente o # factura..."
                           class="form-control" style="padding-left:34px;">
                </div>
                <input type="date" name="fecha_desde" value="<?= htmlspecialchars($fechaD) ?>"
                       class="form-control" style="max-width:150px;" placeholder="Desde">
                <input type="date" name="fecha_hasta" value="<?= htmlspecialchars($fechaH) ?>"
                       class="form-control" style="max-width:150px;" placeholder="Hasta">
                <button type="submit" class="btn-og-primary" style="padding:8px 16px;">
                    <i class="fas fa-search me-1"></i>Filtrar
                </button>
            </div>
            <a href="<?= APP_URL ?>Facturacion/nuevo" class="btn-og-primary">
                <i class="fas fa-plus"></i> Nueva Factura
            </a>
        </form>
    </div>

    <!-- Tabla -->
    <div class="kpi-card" style="padding:0;">
        <div style="overflow-x:auto;">
            <table class="tabla-og">
                <thead>
                    <tr>
                        <th># Factura</th>
                        <th>Fecha</th>
                        <th>Paciente</th>
                        <th>Subtotal</th>
                        <th>ISV (15%)</th>
                        <th>Total</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <?php if (empty($facturas)): ?>
                    <tr>
                        <td colspan="8" class="text-center py-5 text-muted">
                            <i class="fas fa-file-times fa-2x mb-2 d-block" style="opacity:.25;"></i>
                            No se encontraron facturas
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($facturas as $f): ?>
                    <tr>
                        <td>
                            <span style="font-weight:700;color:#1A56AB;font-size:.85rem;">
                                #<?= str_pad($f['id_factura'], 5, '0', STR_PAD_LEFT) ?>
                            </span>
                        </td>
                        <td style="font-size:.84rem;color:#6B7280;"><?= htmlspecialchars($f['fecha'] ?? '') ?></td>
                        <td style="font-weight:500;color:#1A2940;"><?= htmlspecialchars($f['paciente'] ?? '—') ?></td>
                        <td style="font-size:.87rem;"><?= $fmt((float)($f['subtotal'] ?? 0)) ?></td>
                        <td style="font-size:.87rem;color:#6B7280;"><?= $fmt((float)($f['isv'] ?? 0)) ?></td>
                        <td style="font-weight:700;color:#1A2940;"><?= $fmt((float)($f['total'] ?? 0)) ?></td>
                        <td>
                            <?php $est = strtolower($f['estado'] ?? ''); ?>
                            <span class="badge-og badge-<?= $est ?>">
                                <?= ucfirst($est) ?>
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;">
                                <a href="<?= APP_URL ?>Facturacion/ver/<?= $f['id_factura'] ?>"
                                   class="btn btn-sm" title="Ver detalle"
                                   style="background:#EEF3FC;color:#1A56AB;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="<?= APP_URL ?>Facturacion/imprimir/<?= $f['id_factura'] ?>"
                                   class="btn btn-sm" title="Imprimir"
                                   style="background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;border-radius:6px;padding:5px 10px;font-size:.8rem;" target="_blank">
                                    <i class="fas fa-print"></i>
                                </a>
                                <?php if ($est === 'pendiente'): ?>
                                <button class="btn btn-sm" title="Marcar pagada" onclick="marcarPagada(<?= $f['id_factura'] ?>)"
                                        style="background:rgba(22,163,74,.08);color:#16a34a;border:none;border-radius:6px;padding:5px 10px;font-size:.8rem;">
                                    <i class="fas fa-check"></i>
                                </button>
                                <?php endif; ?>
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
            <span style="font-size:.8rem;color:#6B7280;"><?= $total ?> facturas — Página <?= $page ?> de <?= $totalPag ?></span>
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

<script>
function marcarPagada(id){
    Swal.fire({
        title:'¿Marcar como pagada?',
        icon:'question',
        showCancelButton:true,
        confirmButtonColor:'#16a34a',
        confirmButtonText:'Sí, confirmar',
        cancelButtonText:'Cancelar'
    }).then(r=>{
        if(!r.isConfirmed)return;
        fetch('<?= APP_URL ?>Facturacion/cambiarEstado',{
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body:JSON.stringify({id_factura:id,estado:'pagada',_csrf:'<?= htmlspecialchars(Csrf::token()) ?>'})
        }).then(r=>r.json()).then(d=>{
            if(d.success) location.reload();
            else Swal.fire('Error',d.error||'No se pudo actualizar','error');
        });
    });
}
</script>
