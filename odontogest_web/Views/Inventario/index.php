<?php
$q         = trim($_GET['q'] ?? '');
$categoria = $_GET['categoria'] ?? '';
$page      = (int)($_GET['page'] ?? 1);
$productos = $productos ?? [];
$total     = $total    ?? 0;
$totalPag  = $totalPag ?? 1;
$kpis      = $kpis     ?? ['total_productos'=>0,'bajo_minimo'=>0,'sin_stock'=>0,'valor_total'=>0];
$categorias= $categorias ?? [];
$alertas   = $alertas   ?? [];
?>
<div style="padding:24px 28px;">

    <!-- KPIs -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon blue"><i class="fas fa-boxes-stacked"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['total_productos'] ?? 0)) ?></div>
                <div class="kpi-label">Productos registrados</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon amber"><i class="fas fa-exclamation-triangle"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['bajo_minimo'] ?? 0)) ?></div>
                <div class="kpi-label">Bajo mínimo</div>
                <?php if ((int)($kpis['bajo_minimo'] ?? 0) > 0): ?>
                <div class="kpi-badge down"><i class="fas fa-bell me-1"></i>Requiere reposición</div>
                <?php endif; ?>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon red"><i class="fas fa-box-open"></i></div>
                <div class="kpi-value"><?= number_format((int)($kpis['sin_stock'] ?? 0)) ?></div>
                <div class="kpi-label">Sin stock</div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kpi-card">
                <div class="kpi-icon green"><i class="fas fa-dollar-sign"></i></div>
                <div class="kpi-value" style="font-size:1.4rem;">
                    L <?= number_format((float)($kpis['valor_total'] ?? 0), 0, '.', ',') ?>
                </div>
                <div class="kpi-label">Valor total inventario</div>
            </div>
        </div>
    </div>

    <!-- Layout 2 col: tabla izquierda + alertas derecha -->
    <div class="row g-3">

        <!-- Tabla principal (2/3) -->
        <div class="col-12 col-lg-8">

            <!-- Filtros -->
            <div class="kpi-card" style="padding:14px 18px;margin-bottom:14px;">
                <form method="GET" style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:space-between;">
                    <div style="display:flex;gap:10px;flex:1;flex-wrap:wrap;">
                        <div style="position:relative;flex:1;min-width:180px;">
                            <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:.82rem;"></i>
                            <input type="text" name="q" value="<?= htmlspecialchars($q) ?>"
                                   placeholder="Buscar producto..."
                                   class="form-control" style="padding-left:34px;">
                        </div>
                        <?php if (!empty($categorias)): ?>
                        <select name="categoria" class="form-select" style="max-width:160px;">
                            <option value="">Todas las categorías</option>
                            <?php foreach ($categorias as $cat): ?>
                            <option value="<?= htmlspecialchars($cat['id_categoria']) ?>"
                                    <?= $categoria == $cat['id_categoria'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($cat['nombre']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                        <?php endif; ?>
                        <button type="submit" class="btn-og-primary" style="padding:8px 14px;">
                            <i class="fas fa-search me-1"></i>Buscar
                        </button>
                    </div>
                    <a href="<?= APP_URL ?>Inventario/nuevo" class="btn-og-primary">
                        <i class="fas fa-plus"></i> Agregar
                    </a>
                </form>
            </div>

            <!-- Tabla -->
            <div class="kpi-card" style="padding:0;">
                <div style="overflow-x:auto;">
                    <table class="tabla-og">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Categoría</th>
                                <th>Stock</th>
                                <th>Mínimo</th>
                                <th>Precio Unit.</th>
                                <th>Estado</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php if (empty($productos)): ?>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fas fa-boxes-stacked fa-2x mb-2 d-block" style="opacity:.25;"></i>
                                    No se encontraron productos
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($productos as $p):
                                $stock = (int)($p['stock_actual'] ?? 0);
                                $min   = (int)($p['stock_minimo'] ?? 0);
                                if ($stock === 0)        { $stClass = 'badge-critico'; $stLbl = 'Sin stock'; }
                                elseif ($stock <= $min)  { $stClass = 'badge-bajo';    $stLbl = 'Bajo'; }
                                else                     { $stClass = 'badge-ok';      $stLbl = 'OK'; }
                            ?>
                            <tr>
                                <td>
                                    <div style="font-weight:600;color:#1A2940;"><?= htmlspecialchars($p['nombre'] ?? '—') ?></div>
                                    <?php if (!empty($p['codigo'])): ?>
                                    <div style="font-size:.72rem;color:#9CA3AF;">Cód: <?= htmlspecialchars($p['codigo']) ?></div>
                                    <?php endif; ?>
                                </td>
                                <td style="font-size:.83rem;color:#6B7280;"><?= htmlspecialchars($p['categoria'] ?? '—') ?></td>
                                <td>
                                    <span style="font-size:1rem;font-weight:700;color:<?= $stock===0 ? '#dc2626' : ($stock<=$min ? '#d97706' : '#16a34a') ?>;">
                                        <?= $stock ?>
                                    </span>
                                    <span style="font-size:.74rem;color:#9CA3AF;"> uds</span>
                                </td>
                                <td style="font-size:.83rem;color:#9CA3AF;"><?= $min ?></td>
                                <td style="font-weight:600;color:#1A2940;font-size:.87rem;">
                                    L <?= number_format((float)($p['precio_unitario'] ?? 0), 2) ?>
                                </td>
                                <td><span class="badge-og <?= $stClass ?>"><?= $stLbl ?></span></td>
                                <td>
                                    <div style="display:flex;gap:5px;">
                                        <a href="<?= APP_URL ?>Inventario/editar/<?= $p['id_producto'] ?>"
                                           style="background:#EEF3FC;color:#1A56AB;border:none;border-radius:6px;padding:5px 9px;font-size:.78rem;display:inline-block;">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="<?= APP_URL ?>Inventario/movimiento/<?= $p['id_producto'] ?>"
                                           style="background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;border-radius:6px;padding:5px 9px;font-size:.78rem;display:inline-block;">
                                            <i class="fas fa-exchange-alt"></i>
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
                <div style="padding:12px 18px;border-top:1px solid #DDE4EF;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
                    <span style="font-size:.8rem;color:#6B7280;"><?= $total ?> productos — Pág. <?= $page ?>/<?= $totalPag ?></span>
                    <div style="display:flex;gap:4px;">
                        <?php for ($i=max(1,$page-2);$i<=min($totalPag,$page+2);$i++): ?>
                        <a href="?<?= http_build_query(array_merge($_GET,['page'=>$i])) ?>"
                           style="width:30px;height:30px;display:flex;align-items:center;justify-content:center;
                                  border-radius:6px;font-size:.8rem;font-weight:600;text-decoration:none;
                                  <?= $i===$page?'background:#1A56AB;color:#fff;':'background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;' ?>">
                            <?= $i ?>
                        </a>
                        <?php endfor; ?>
                    </div>
                </div>
                <?php endif; ?>
            </div>
        </div>

        <!-- Panel alertas (1/3) -->
        <div class="col-12 col-lg-4">
            <div class="kpi-card" style="padding:0;position:sticky;top:76px;">
                <div style="padding:14px 18px;border-bottom:1px solid #DDE4EF;">
                    <span style="font-size:.9rem;font-weight:700;color:#1A2940;">
                        <i class="fas fa-exclamation-triangle me-1" style="color:#dc2626;"></i>
                        Alertas de Stock
                    </span>
                    <?php if (!empty($alertas)): ?>
                    <span style="float:right;background:rgba(220,38,38,.1);color:#dc2626;border-radius:12px;padding:2px 8px;font-size:.72rem;font-weight:700;">
                        <?= count($alertas) ?>
                    </span>
                    <?php endif; ?>
                </div>
                <div style="max-height:calc(100vh - 300px);overflow-y:auto;">
                    <?php if (empty($alertas)): ?>
                    <div class="text-center py-5 text-muted" style="font-size:.84rem;">
                        <i class="fas fa-check-circle fa-2x mb-2 d-block" style="color:#16a34a;opacity:.5;"></i>
                        Sin alertas de stock
                    </div>
                    <?php else: ?>
                    <?php foreach ($alertas as $a):
                        $s = (int)($a['stock_actual'] ?? 0);
                        $critico = $s === 0;
                    ?>
                    <div style="padding:12px 16px;border-bottom:1px solid #F0F3F8;
                                background:<?= $critico ? 'rgba(220,38,38,.03)' : 'rgba(217,119,6,.03)' ?>;">
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px;">
                            <div>
                                <div style="font-size:.83rem;font-weight:600;color:#1A2940;">
                                    <?= htmlspecialchars($a['nombre'] ?? '—') ?>
                                </div>
                                <div style="font-size:.73rem;color:#6B7280;margin-top:2px;">
                                    <?= htmlspecialchars($a['categoria'] ?? '') ?>
                                </div>
                            </div>
                            <div class="text-end flex-shrink-0">
                                <div style="font-size:.95rem;font-weight:800;color:<?= $critico?'#dc2626':'#d97706' ?>;">
                                    <?= $s ?>
                                </div>
                                <div style="font-size:.7rem;color:#9CA3AF;">de <?= (int)($a['stock_minimo']??0) ?> mín.</div>
                            </div>
                        </div>
                        <div style="margin-top:6px;height:4px;background:#F0F3F8;border-radius:3px;overflow:hidden;">
                            <?php $pct = $a['stock_minimo'] ? min(100, round(($s / $a['stock_minimo']) * 100)) : 0; ?>
                            <div style="height:100%;width:<?= $pct ?>%;background:<?= $critico?'#dc2626':'#d97706' ?>;border-radius:3px;"></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>

    </div><!-- /row -->
</div>
