<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle = 'Panel general';
$active = 'dashboard';

$stats = [
    'patients' => (int)$pdo->query("SELECT COUNT(*) FROM pacientes")->fetchColumn(),
    'doctors' => (int)$pdo->query("SELECT COUNT(*) FROM medicos WHERE estado='ACTIVO'")->fetchColumn(),
    'appointments' => (int)$pdo->query("SELECT COUNT(*) FROM citas")->fetchColumn(),
    'income' => (float)$pdo->query("SELECT COALESCE(SUM(monto),0) FROM pagos WHERE estado_pago='CONFIRMADO'")->fetchColumn(),
];
$today = date('Y-m-d');
$stmt = $pdo->prepare("SELECT c.id_cita,c.fecha_hora,c.estado_cita,CONCAT(p.nombres,' ',p.apellidos) paciente,CONCAT(m.nombres,' ',m.apellidos) medico,e.nombre especialidad,c.costo_total FROM citas c JOIN pacientes p ON p.id_paciente=c.id_paciente JOIN medicos m ON m.id_medico=c.id_medico JOIN especialidades e ON e.id_especialidad=c.id_especialidad WHERE DATE(c.fecha_hora)=? ORDER BY c.fecha_hora LIMIT 8");
$stmt->execute([$today]);
$todayAppointments = $stmt->fetchAll();

$incomeByMethod = $pdo->query("SELECT metodo_pago,SUM(monto) total FROM pagos WHERE estado_pago='CONFIRMADO' GROUP BY metodo_pago ORDER BY total DESC")->fetchAll();
$maxIncome = max(array_map(fn($r)=>(float)$r['total'], $incomeByMethod) ?: [1]);
$pageTitle = 'Panel general';
require __DIR__ . '/includes/header.php';
?>
<div class="page-heading">
  <div><div class="eyebrow">RESUMEN EJECUTIVO</div><h1>Panel general</h1><p>Bienvenido. Aquí tienes el resumen de actividad de tu clínica.</p></div>
  <div class="heading-actions"><span class="date-chip">◷ <?= date('d/m/Y') ?></span><a class="btn btn-primary" href="appointments.php?action=create">＋ Nueva cita</a></div>
</div>

<div class="welcome-banner">
  <div><span class="banner-kicker">GESTIÓN INTELIGENTE</span><h2>Una visión clara de tu clínica.</h2><p>Administra pacientes, profesionales, citas y pagos desde un solo lugar.</p></div>
  <div class="banner-art"><div class="art-circle">✚</div><span class="art-cross">＋</span><span class="art-dot"></span></div>
</div>

<div class="stats-grid">
  <article class="stat-card"><div class="stat-top"><span class="stat-icon cyan">♙</span><span class="stat-caption">REGISTRO</span></div><div class="stat-value"><?= number_format($stats['patients']) ?></div><div class="stat-label">Pacientes registrados</div><a href="patients.php">Ver pacientes <span>→</span></a></article>
  <article class="stat-card"><div class="stat-top"><span class="stat-icon violet">✚</span><span class="stat-caption">EQUIPO MÉDICO</span></div><div class="stat-value"><?= number_format($stats['doctors']) ?></div><div class="stat-label">Médicos activos</div><a href="doctors.php">Ver médicos <span>→</span></a></article>
  <article class="stat-card"><div class="stat-top"><span class="stat-icon blue">▣</span><span class="stat-caption">ATENCIONES</span></div><div class="stat-value"><?= number_format($stats['appointments']) ?></div><div class="stat-label">Citas registradas</div><a href="appointments.php">Ver citas <span>→</span></a></article>
  <article class="stat-card"><div class="stat-top"><span class="stat-icon green">S/</span><span class="stat-caption">RECAUDACIÓN</span></div><div class="stat-value money-value"><?= money($stats['income']) ?></div><div class="stat-label">Pagos confirmados acumulados</div><a href="payments.php">Ver pagos <span>→</span></a></article>
</div>

<div class="dashboard-grid">
  <section class="panel">
    <div class="panel-heading"><div><h3>Agenda de hoy</h3><p>Citas programadas para <?= date('d/m/Y') ?></p></div><a class="text-link" href="appointments.php">Ver todas →</a></div>
    <?php if (!$todayAppointments): ?><div class="empty-state"><span>▣</span><strong>No hay citas para hoy</strong><p>Cuando registres citas para esta fecha, aparecerán aquí.</p><a class="btn btn-outline" href="appointments.php?action=create">Registrar una cita</a></div>
    <?php else: ?><div class="table-wrap"><table><thead><tr><th>HORA</th><th>PACIENTE</th><th>MÉDICO</th><th>ESPECIALIDAD</th><th>ESTADO</th></tr></thead><tbody>
    <?php foreach($todayAppointments as $a): ?><tr><td class="time-cell"><?= date('H:i',strtotime($a['fecha_hora'])) ?></td><td><strong><?= e($a['paciente']) ?></strong></td><td><?= e($a['medico']) ?></td><td><?= e($a['especialidad']) ?></td><td><span class="badge <?= status_class($a['estado_cita']) ?>"><?= e($a['estado_cita']) ?></span></td></tr><?php endforeach; ?>
    </tbody></table></div><?php endif; ?>
  </section>
  <section class="panel">
    <div class="panel-heading"><div><h3>Pagos por método</h3><p>Distribución de pagos confirmados</p></div><span class="panel-icon">＄</span></div>
    <?php if (!$incomeByMethod): ?><div class="empty-state compact"><p>Aún no hay pagos registrados.</p></div><?php else: ?>
      <div class="bar-list"><?php foreach($incomeByMethod as $r): $pct=$maxIncome>0?((float)$r['total']/$maxIncome)*100:0; ?><div class="bar-item"><div class="bar-meta"><span><?= e($r['metodo_pago']) ?></span><strong><?= money($r['total']) ?></strong></div><div class="bar-track"><span style="width:<?= number_format($pct,1,'.','') ?>%"></span></div></div><?php endforeach; ?></div>
    <?php endif; ?>
    <a class="btn btn-outline full-btn" href="payments.php">Administrar pagos</a>
  </section>
</div>

<div class="quick-links"><a href="patients.php?action=create"><span class="quick-icon cyan">♙</span><span><strong>Nuevo paciente</strong><small>Registrar datos personales</small></span><b>→</b></a><a href="doctors.php"><span class="quick-icon violet">✚</span><span><strong>Equipo médico</strong><small>Ver médicos y especialidades</small></span><b>→</b></a><a href="consultations.php"><span class="quick-icon blue">▤</span><span><strong>Consultas</strong><small>Revisar atenciones realizadas</small></span><b>→</b></a></div>
<?php require __DIR__ . '/includes/footer.php'; ?>
