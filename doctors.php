<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle='Médicos'; $active='doctors';
$doctors=$pdo->query("SELECT m.*,GROUP_CONCAT(e.nombre ORDER BY e.nombre SEPARATOR ', ') especialidades FROM medicos m LEFT JOIN medico_especialidad me ON me.id_medico=m.id_medico LEFT JOIN especialidades e ON e.id_especialidad=me.id_especialidad GROUP BY m.id_medico ORDER BY m.apellidos")->fetchAll();
$specialties=$pdo->query("SELECT * FROM especialidades WHERE estado='ACTIVO' ORDER BY nombre")->fetchAll();
require __DIR__.'/includes/header.php';
?>
<div class="page-heading"><div><div class="eyebrow">TALENTO MÉDICO</div><h1>Médicos</h1><p>Consulta el equipo profesional y sus especialidades asignadas.</p></div><span class="date-chip"><?= count($doctors) ?> profesionales</span></div>
<section class="panel"><div class="panel-heading"><div><h3>Equipo médico</h3><p>Información profesional registrada en CLINISYS.</p></div></div>
<div class="doctor-grid"><?php foreach($doctors as $d): ?><article class="doctor-card"><div class="doctor-avatar"><?= e(strtoupper(substr($d['nombres'],0,1).substr($d['apellidos'],0,1))) ?></div><div class="doctor-info"><span class="badge <?= status_class($d['estado']) ?>"><?= e($d['estado']) ?></span><h3><?= e($d['nombres'].' '.$d['apellidos']) ?></h3><p><?= e($d['especialidades']?:'Sin especialidad asignada') ?></p><small>CMP: <?= e($d['numero_colegiatura']) ?></small><small><?= e($d['correo']?:'Correo no registrado') ?></small></div></article><?php endforeach; ?></div>
<?php if(!$doctors): ?><div class="empty-state">No hay médicos registrados todavía.</div><?php endif; ?></section>
<section class="panel"><div class="panel-heading"><div><h3>Especialidades disponibles</h3><p>Catálogo de especialidades de la clínica.</p></div></div><div class="specialty-list"><?php foreach($specialties as $s): ?><span class="specialty-pill">✚ <?= e($s['nombre']) ?></span><?php endforeach; ?></div></section>
<?php require __DIR__.'/includes/footer.php'; ?>
