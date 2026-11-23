<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle='Citas médicas'; $active='appointments';
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf();
 $data=[(int)$_POST['id_paciente'],(int)$_POST['id_medico'],(int)$_POST['id_especialidad'],$_POST['fecha_hora'],(int)$_POST['duracion_minutos'],trim($_POST['motivo']), (float)$_POST['costo_total'],$_POST['estado_cita'],trim($_POST['observaciones']??'')];
 try{$pdo->prepare("INSERT INTO citas (id_paciente,id_medico,id_especialidad,fecha_hora,duracion_minutos,motivo,costo_total,estado_cita,observaciones) VALUES (?,?,?,?,?,?,?,?,?)")->execute($data);flash('success','Cita registrada correctamente.');}
 catch(PDOException $ex){flash('error','No se pudo registrar la cita. Verifica que el médico tenga asignada esa especialidad y que no exista cruce de horario.');}
 redirect('appointments.php');
}
if(isset($_GET['status'],$_GET['id'])){
 $allowed=['PROGRAMADA','CONFIRMADA','ATENDIDA','CANCELADA','NO_ASISTIO'];$status=$_GET['status'];
 if(in_array($status,$allowed,true)){try{$pdo->prepare("UPDATE citas SET estado_cita=? WHERE id_cita=?")->execute([$status,(int)$_GET['id']]);flash('success','Estado de la cita actualizado.');}catch(PDOException $ex){flash('error','No se pudo actualizar el estado.');}}
 redirect('appointments.php');
}
$rows=$pdo->query("SELECT * FROM vw_citas_detalladas ORDER BY fecha_hora DESC")->fetchAll();
$patients=$pdo->query("SELECT id_paciente,CONCAT(nombres,' ',apellidos) nombre FROM pacientes WHERE estado='ACTIVO' ORDER BY apellidos")->fetchAll();
$doctors=$pdo->query("SELECT id_medico,CONCAT(nombres,' ',apellidos) nombre FROM medicos WHERE estado='ACTIVO' ORDER BY apellidos")->fetchAll();
$specialties=$pdo->query("SELECT * FROM especialidades WHERE estado='ACTIVO' ORDER BY nombre")->fetchAll();
$showForm=isset($_GET['action'])&&$_GET['action']==='create';
require __DIR__.'/includes/header.php';
?>
<div class="page-heading"><div><div class="eyebrow">AGENDA Y ATENCIONES</div><h1>Citas médicas</h1><p>Programa citas y administra el estado de las atenciones.</p></div><a class="btn btn-primary" href="appointments.php?action=create">＋ Nueva cita</a></div>
<?php if($showForm): ?><section class="panel form-panel"><div class="panel-heading"><div><h3>Programar nueva cita</h3><p>Selecciona paciente, médico y especialidad.</p></div><a class="text-link" href="appointments.php">✕ Cerrar</a></div>
<form method="post" class="form-grid"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
<label>Paciente *<select name="id_paciente" required><option value="">Seleccionar paciente</option><?php foreach($patients as $p): ?><option value="<?= (int)$p['id_paciente'] ?>"><?= e($p['nombre']) ?></option><?php endforeach; ?></select></label>
<label>Médico *<select name="id_medico" required><option value="">Seleccionar médico</option><?php foreach($doctors as $d): ?><option value="<?= (int)$d['id_medico'] ?>"><?= e($d['nombre']) ?></option><?php endforeach; ?></select></label>
<label>Especialidad *<select name="id_especialidad" required><option value="">Seleccionar especialidad</option><?php foreach($specialties as $s): ?><option value="<?= (int)$s['id_especialidad'] ?>"><?= e($s['nombre']) ?></option><?php endforeach; ?></select><small>La base de datos verificará que esté asignada al médico.</small></label>
<label>Fecha y hora *<input type="datetime-local" name="fecha_hora" required></label>
<label>Duración (minutos) *<input type="number" name="duracion_minutos" min="5" max="240" value="30" required></label>
<label>Costo (S/) *<input type="number" name="costo_total" min="0" step="0.01" value="100.00" required></label>
<label class="span-2">Motivo de la cita *<input name="motivo" maxlength="255" required></label>
<label>Estado<select name="estado_cita"><option>PROGRAMADA</option><option>CONFIRMADA</option></select></label>
<label>Observaciones<input name="observaciones" maxlength="255"></label>
<div class="form-actions span-2"><a class="btn btn-outline" href="appointments.php">Cancelar</a><button class="btn btn-primary">Guardar cita</button></div></form></section><?php endif; ?>
<section class="panel"><div class="panel-heading"><div><h3>Listado de citas</h3><p><?= count($rows) ?> citas registradas</p></div><span class="panel-icon">▣</span></div><div class="table-wrap"><table><thead><tr><th>FECHA Y HORA</th><th>PACIENTE</th><th>MÉDICO</th><th>ESPECIALIDAD</th><th>COSTO</th><th>ESTADO</th><th>ACTUALIZAR</th></tr></thead><tbody>
<?php foreach($rows as $r): ?><tr><td class="time-cell"><?= date('d/m/Y H:i',strtotime($r['fecha_hora'])) ?></td><td><strong><?= e($r['paciente']) ?></strong></td><td><?= e($r['medico']) ?></td><td><?= e($r['especialidad']) ?></td><td><?= money($r['costo_total']) ?></td><td><span class="badge <?= status_class($r['estado_cita']) ?>"><?= e($r['estado_cita']) ?></span></td><td><select class="inline-status" data-status-url="appointments.php?id=<?= (int)$r['id_cita'] ?>&status="><option value="">Cambiar...</option><?php foreach(['PROGRAMADA','CONFIRMADA','ATENDIDA','CANCELADA','NO_ASISTIO'] as $s): ?><option value="<?= $s ?>"><?= $s ?></option><?php endforeach; ?></select></td></tr><?php endforeach; ?>
<?php if(!$rows): ?><tr><td colspan="7"><div class="empty-state compact">No hay citas registradas.</div></td></tr><?php endif; ?></tbody></table></div></section>
<?php require __DIR__.'/includes/footer.php'; ?>
