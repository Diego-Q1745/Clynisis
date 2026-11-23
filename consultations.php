<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle='Consultas'; $active='consultations';
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf();
 $id=(int)$_POST['id_cita'];
 $data=[$id,trim($_POST['diagnostico']),trim($_POST['tratamiento']??''),trim($_POST['recomendaciones']??''),trim($_POST['observaciones']??'')];
 try{
   $stmt=$pdo->prepare("INSERT INTO consultas (id_cita,diagnostico,tratamiento,recomendaciones,observaciones) SELECT ?,?,?,?,? FROM citas WHERE id_cita=? AND estado_cita='ATENDIDA' AND NOT EXISTS (SELECT 1 FROM consultas WHERE id_cita=?)");
   $stmt->execute([$id,$data[1],$data[2],$data[3],$data[4],$id,$id]);
   if($stmt->rowCount()) flash('success','Consulta registrada correctamente.'); else flash('error','La cita debe estar ATENDIDA y no tener una consulta previa.');
 }catch(PDOException $ex){flash('error','No se pudo registrar la consulta. Comprueba que la cita esté atendida y no tenga otra consulta.');}
 redirect('consultations.php');
}
$rows=$pdo->query("SELECT co.*,c.fecha_hora,CONCAT(p.nombres,' ',p.apellidos) paciente,CONCAT(m.nombres,' ',m.apellidos) medico,e.nombre especialidad FROM consultas co JOIN citas c ON c.id_cita=co.id_cita JOIN pacientes p ON p.id_paciente=c.id_paciente JOIN medicos m ON m.id_medico=c.id_medico JOIN especialidades e ON e.id_especialidad=c.id_especialidad ORDER BY co.fecha_consulta DESC")->fetchAll();
$available=$pdo->query("SELECT c.id_cita,c.fecha_hora,CONCAT(p.nombres,' ',p.apellidos) paciente FROM citas c JOIN pacientes p ON p.id_paciente=c.id_paciente LEFT JOIN consultas co ON co.id_cita=c.id_cita WHERE c.estado_cita='ATENDIDA' AND co.id_consulta IS NULL ORDER BY c.fecha_hora DESC")->fetchAll();
$showForm=isset($_GET['action'])&&$_GET['action']==='create';
require __DIR__.'/includes/header.php';
?>
<div class="page-heading"><div><div class="eyebrow">REGISTRO DE ATENCIÓN</div><h1>Consultas</h1><p>Consulta las atenciones registradas y documenta nuevas consultas.</p></div><a class="btn btn-primary" href="consultations.php?action=create">＋ Registrar consulta</a></div>
<?php if($showForm): ?><section class="panel form-panel"><div class="panel-heading"><div><h3>Nueva consulta</h3><p>Solo aparecen citas marcadas como atendidas sin consulta registrada.</p></div><a class="text-link" href="consultations.php">✕ Cerrar</a></div>
<form method="post" class="form-grid"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><label class="span-2">Cita atendida *<select name="id_cita" required><option value="">Seleccionar cita</option><?php foreach($available as $a): ?><option value="<?= (int)$a['id_cita'] ?>">#<?= (int)$a['id_cita'] ?> · <?= e($a['paciente']) ?> · <?= date('d/m/Y H:i',strtotime($a['fecha_hora'])) ?></option><?php endforeach; ?></select></label><label class="span-2">Diagnóstico *<textarea name="diagnostico" rows="3" required></textarea></label><label class="span-2">Tratamiento<textarea name="tratamiento" rows="3"></textarea></label><label class="span-2">Recomendaciones<textarea name="recomendaciones" rows="2"></textarea></label><label class="span-2">Observaciones<textarea name="observaciones" rows="2"></textarea></label><div class="form-actions span-2"><a class="btn btn-outline" href="consultations.php">Cancelar</a><button class="btn btn-primary">Guardar consulta</button></div></form></section><?php endif; ?>
<section class="panel"><div class="panel-heading"><div><h3>Historial de consultas</h3><p><?= count($rows) ?> consulta(s) registradas</p></div></div><div class="table-wrap"><table><thead><tr><th>FECHA</th><th>PACIENTE</th><th>MÉDICO</th><th>ESPECIALIDAD</th><th>DIAGNÓSTICO</th></tr></thead><tbody><?php foreach($rows as $r): ?><tr><td><?= date('d/m/Y',strtotime($r['fecha_consulta'])) ?></td><td><strong><?= e($r['paciente']) ?></strong></td><td><?= e($r['medico']) ?></td><td><?= e($r['especialidad']) ?></td><td class="wrap-cell"><?= e($r['diagnostico']) ?></td></tr><?php endforeach; ?><?php if(!$rows): ?><tr><td colspan="5"><div class="empty-state compact">No hay consultas registradas.</div></td></tr><?php endif; ?></tbody></table></div></section>
<?php require __DIR__.'/includes/footer.php'; ?>
