<?php $csrf = Csrf::token(); ?>
<div><div style="padding:24px 28px;">
<!-- KPIs -->
<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;">
<?php foreach([
    ['label'=>'Emitidas',     'val'=>$kpis['emitidas']??0,       'icon'=>'fa-file-invoice-dollar','color'=>'amber'],
    ['label'=>'Pagadas',      'val'=>$kpis['pagadas']??0,        'icon'=>'fa-check-circle',       'color'=>'green'],
    ['label'=>'Ingresos Mes', 'val'=>'L. '.number_format($kpis['ingresos_mes']??0,2),'icon'=>'fa-coins','color'=>'blue'],
    ['label'=>'Pendiente',    'val'=>'L. '.number_format($kpis['monto_pendiente']??0,2),'icon'=>'fa-clock','color'=>'red'],
] as $k): ?>
<div class="kpi-card">
    <div style="display:flex;align-items:center;gap:14px;">
        <div class="kpi-icon <?= $k['color'] ?>"><i class="fas <?= $k['icon'] ?>"></i></div>
        <div><div class="kpi-value" style="font-size:<?= strlen($k['val'])>6?'16px':'22px' ?>;"><?= $k['val'] ?></div><div class="kpi-label"><?= $k['label'] ?></div></div>
    </div>
</div>
<?php endforeach; ?>
</div>

<!-- Filtros -->
<div class="kpi-card" style="margin-bottom:20px;">
    <form method="GET" style="display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;">
        <div style="flex:1;min-width:130px;"><label class="form-label">Estado</label>
            <select name="estado" class="form-select"><option value="">Todos</option>
                <?php foreach(['emitida','pagada','anulada'] as $e): ?><option value="<?= $e ?>" <?= $filtros['estado']===$e?'selected':'' ?>><?= ucfirst($e) ?></option><?php endforeach; ?>
            </select></div>
        <div style="flex:1;min-width:140px;"><label class="form-label">Desde</label><input type="date" name="fecha_ini" class="form-control" value="<?= htmlspecialchars($filtros['fecha_ini']) ?>"></div>
        <div style="flex:1;min-width:140px;"><label class="form-label">Hasta</label><input type="date" name="fecha_fin" class="form-control" value="<?= htmlspecialchars($filtros['fecha_fin']) ?>"></div>
        <div style="flex:2;min-width:180px;"><label class="form-label">Buscar</label><input type="text" name="buscar" class="form-control" placeholder="Paciente / N° factura..." value="<?= htmlspecialchars($filtros['buscar']) ?>"></div>
        <div style="display:flex;gap:8px;"><button type="submit" class="btn-og-primary"><i class="fas fa-search me-1"></i>Filtrar</button><a href="<?= APP_URL ?>facturacion" class="btn-og-secondary">Limpiar</a></div>
    </form>
</div>

<!-- Tabla -->
<div class="kpi-card" style="padding:0;overflow:hidden;">
    <div style="padding:14px 20px;border-bottom:1px solid var(--card-border);display:flex;justify-content:space-between;align-items:center;">
        <span style="font-weight:600;color:var(--body-text);">Facturas <span style="font-size:12px;color:#9CA3AF;">(<?= $total ?>)</span></span>
    </div>
    <div style="overflow-x:auto;">
    <table class="tabla-og">
        <thead><tr><th>N° Factura</th><th>Fecha</th><th>Paciente</th><th>Subtotal</th><th>ISV</th><th>Total</th><th>Método</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
        <?php if(empty($facturas)): ?>
        <tr><td colspan="9" style="text-align:center;padding:40px;color:#9CA3AF;"><i class="fas fa-file-invoice fa-2x d-block mb-2" style="opacity:.3;"></i>Sin facturas</td></tr>
        <?php else: foreach($facturas as $f): ?>
        <tr>
            <td style="font-weight:600;color:#1A56AB;"><?= htmlspecialchars($f['numero_factura']) ?></td>
            <td><?= $f['fecha'] ?></td>
            <td><?= htmlspecialchars($f['paciente']) ?></td>
            <td>L. <?= number_format($f['subtotal'],2) ?></td>
            <td>L. <?= number_format($f['impuesto'],2) ?></td>
            <td style="font-weight:700;">L. <?= number_format($f['total'],2) ?></td>
            <td><?= ucfirst($f['metodo_pago']) ?></td>
            <td><span class="badge badge-<?= $f['estado'] ?>"><?= ucfirst($f['estado']) ?></span></td>
            <td>
                <div style="display:flex;gap:6px;">
                    <?php if($f['estado']==='emitida'): ?>
                    <button class="btn-og-icon" title="Marcar pagada" onclick="marcarPagada(<?= $f['id_factura'] ?>)" style="color:#16A34A;"><i class="fas fa-check"></i></button>
                    <button class="btn-og-icon btn-danger-icon" title="Anular" onclick="anularFactura(<?= $f['id_factura'] ?>)"><i class="fas fa-ban"></i></button>
                    <?php endif; ?>
                </div>
            </td>
        </tr>
        <?php endforeach; endif; ?>
        </tbody>
    </table>
    </div>
    <?php if($totalPags>1): ?>
    <div style="padding:12px 20px;display:flex;gap:6px;justify-content:center;border-top:1px solid var(--card-border);">
        <?php for($i=1;$i<=$totalPags;$i++): ?>
        <a href="?<?= http_build_query(array_merge($filtros,['pagina'=>$i])) ?>" style="width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:6px;font-size:13px;text-decoration:none;<?= $i===$filtros['pagina']?'background:#1A56AB;color:#fff;':'background:#F5F7FB;color:#374151;border:1px solid #DDE4EF;' ?>"><?= $i ?></a>
        <?php endfor; ?>
    </div>
    <?php endif; ?>
</div>
</div></div>
<style>.btn-og-icon{width:30px;height:30px;border-radius:6px;border:1px solid #DDE4EF;background:#F5F7FB;color:#374151;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;font-size:12px;transition:.15s;}.btn-og-icon:hover{background:#1A56AB;border-color:#1A56AB;color:#fff;}.btn-danger-icon:hover{background:#DC2626;border-color:#DC2626;color:#fff;}[data-theme="dark"] .btn-og-icon{background:#253349;border-color:#334155;color:#CBD5E1;}</style>
<script>
function marcarPagada(id){Swal.fire({title:'¿Marcar como pagada?',icon:'question',showCancelButton:true,confirmButtonColor:'#16A34A',confirmButtonText:'Confirmar',cancelButtonText:'Cancelar'}).then(r=>{if(!r.isConfirmed)return;const fd=new FormData();fd.append('csrf_token','<?= $csrf ?>');fd.append('id_factura',id);fetch('<?= APP_URL ?>facturacion/marcarPagada',{method:'POST',body:fd}).then(()=>location.reload());});}
function anularFactura(id){Swal.fire({title:'Anular factura',input:'text',inputPlaceholder:'Motivo de anulación...',showCancelButton:true,confirmButtonColor:'#DC2626',confirmButtonText:'Anular',cancelButtonText:'Cancelar',inputValidator:v=>!v&&'Ingrese el motivo'}).then(r=>{if(!r.isConfirmed)return;const fd=new FormData();fd.append('csrf_token','<?= $csrf ?>');fd.append('id_factura',id);fd.append('motivo',r.value);fetch('<?= APP_URL ?>facturacion/anular',{method:'POST',body:fd}).then(()=>location.reload());});}
</script>
