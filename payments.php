<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle='Pagos'; $active='payments';
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf();
 $data=[(int)$_POST['id_cita'],(float)$_POST['monto'],$_POST['metodo_pago'],trim($_POST['referencia_pago']??'')?:null];
 try{$pdo->prepare("INSERT INTO pagos (id_cita,monto,metodo_pago,referencia_pago,estado_pago) VALUES (?,?,?,?,'CONFIRMADO')")->execute($data);flash('success','Pago registrado correctamente.');}
 catch(PDOException $ex){flash('error','No se pudo registrar el pago. Comprueba el saldo pendiente de la cita.');}
 redirect('payments.php');
}
$rows=$pdo->query("SELECT p.*,v.costo_total,v.total_pagado,v.saldo_pendiente,v.estado_financiero,CONCAT(pa.nombres,' ',pa.apellidos) paciente FROM pagos p JOIN vw_estado_pagos v ON v.id_cita=p.id_cita JOIN citas c ON c.id_cita=p.id_cita JOIN pacientes pa ON pa.id_paciente=c.id_paciente ORDER BY p.fecha_pago DESC")->fetchAll();
$available=$pdo->query("SELECT v.id_cita,v.saldo_pendiente,CONCAT(p.nombres,' ',p.apellidos) paciente FROM vw_estado_pagos v JOIN citas c ON c.id_cita=v.id_cita JOIN pacientes p ON p.id_paciente=c.id_paciente WHERE v.saldo_pendiente>0 AND c.estado_cita NOT IN ('CANCELADA','NO_ASISTIO') ORDER BY c.fecha_hora DESC")->fetchAll();
$showForm=isset($_GET['action'])&&$_GET['action']==='create';
$total=(float)$pdo->query("SELECT COALESCE(SUM(monto),0) FROM pagos WHERE estado_pago='CONFIRMADO'")->fetchColumn();
$pending=(float)$pdo->query("SELECT COALESCE(SUM(saldo_pendiente),0) FROM vw_estado_pagos")->fetchColumn();
require __DIR__.'/includes/header.php';
?>
<div class="page-heading"><div><div class="eyebrow">CONTROL FINANCIERO</div><h1>Pagos</h1><p>Registra abonos y consulta los saldos pendientes por cita.</p></div><a class="btn btn-primary" href="payments.php?action=create">＋ Registrar pago</a></div>
<div class="mini-stats"><div class="mini-stat"><span>Total confirmado</span><strong><?= money($total) ?></strong></div><div class="mini-stat"><span>Saldo pendiente acumulado</span><strong><?= money($pending) ?></strong></div><div class="mini-stat"><span>Operaciones registradas</span><strong><?= count($rows) ?></strong></div></div>
<?php if($showForm): ?><section class="panel form-panel"><div class="panel-heading"><div><h3>Registrar pago parcial</h3><p>El monto no puede superar el saldo pendiente.</p></div><a class="text-link" href="payments.php">✕ Cerrar</a></div>
<form method="post" class="form-grid"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><label class="span-2">Cita *<select name="id_cita" required><option value="">Seleccionar cita con saldo</option><?php foreach($available as $a): ?><option value="<?= (int)$a['id_cita'] ?>">Cita #<?= (int)$a['id_cita'] ?> · <?= e($a['paciente']) ?> · Saldo <?= money($a['saldo_pendiente']) ?></option><?php endforeach; ?></select></label><label>Monto (S/) *<input type="number" name="monto" min="0.01" step="0.01" required></label><label>Método de pago<select name="metodo_pago"><?php foreach(['EFECTIVO','TARJETA','TRANSFERENCIA','YAPE','PLIN','OTRO'] as $m): ?><option><?= $m ?></option><?php endforeach; ?></select></label><label class="span-2">Referencia de operación<input name="referencia_pago" maxlength="80"></label><div class="form-actions span-2"><a class="btn btn-outline" href="payments.php">Cancelar</a><button class="btn btn-primary">Guardar pago</button></div></form></section><?php endif; ?>
<section class="panel"><div class="panel-heading"><div><h3>Movimientos de pago</h3><p>Los pagos anulados no se consideran en el total confirmado.</p></div></div><div class="table-wrap"><table><thead><tr><th>FECHA</th><th>CITA</th><th>PACIENTE</th><th>MÉTODO</th><th>MONTO</th><th>ESTADO</th></tr></thead><tbody><?php foreach($rows as $r): ?><tr><td><?= date('d/m/Y H:i',strtotime($r['fecha_pago'])) ?></td><td>#<?= (int)$r['id_cita'] ?></td><td><strong><?= e($r['paciente']) ?></strong></td><td><?= e($r['metodo_pago']) ?></td><td><?= money($r['monto']) ?></td><td><span class="badge <?= status_class($r['estado_pago']) ?>"><?= e($r['estado_pago']) ?></span></td></tr><?php endforeach; ?><?php if(!$rows): ?><tr><td colspan="6"><div class="empty-state compact">No hay pagos registrados.</div></td></tr><?php endif; ?></tbody></table></div></section>
<?php require __DIR__.'/includes/footer.php'; ?>
