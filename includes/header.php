<?php
$pageTitle = $pageTitle ?? 'Panel general';
$active = $active ?? 'dashboard';
$flashMessage = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0b1220">
  <title><?= e($pageTitle) ?> | CLINISYS</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/style.css">
  <script defer src="assets/js/app.js"></script>
</head>
<body>
<div class="app-shell">
  <aside class="sidebar" id="sidebar">
    <a class="brand" href="index.php">
      <span class="brand-mark"><span></span><span></span><span></span></span>
      <span>CLINI<span>SYS</span><small>GESTIÓN CLÍNICA</small></span>
    </a>
    <div class="side-label">MENÚ PRINCIPAL</div>
    <nav class="nav">
      <a class="<?= $active==='dashboard'?'active':'' ?>" href="index.php"><b>▦</b> Panel general</a>
      <a class="<?= $active==='patients'?'active':'' ?>" href="patients.php"><b>♙</b> Pacientes</a>
      <a class="<?= $active==='doctors'?'active':'' ?>" href="doctors.php"><b>✚</b> Médicos</a>
      <a class="<?= $active==='appointments'?'active':'' ?>" href="appointments.php"><b>▣</b> Citas médicas</a>
      <a class="<?= $active==='consultations'?'active':'' ?>" href="consultations.php"><b>▤</b> Consultas</a>
      <a class="<?= $active==='payments'?'active':'' ?>" href="payments.php"><b>＄</b> Pagos</a>
    </nav>
    <div class="sidebar-bottom">
      <div class="help-card"><span class="help-icon">✦</span><strong>CLINISYS</strong><p>Administración organizada para una mejor atención.</p><span class="version">Versión 1.0 · Demo académica</span></div>
    </div>
  </aside>
  <main class="main-area">
    <header class="topbar">
      <button class="menu-toggle" id="menuToggle" aria-label="Abrir menú">☰</button>
      <div class="breadcrumb">CLINISYS <span>/</span> <?= e($pageTitle) ?></div>
      <div class="topbar-right"><span class="live-dot"></span><span class="topbar-status">Sistema conectado</span><div class="avatar">AD</div><div class="user-label"><strong>Administrador</strong><small>Panel de gestión</small></div></div>
    </header>
    <section class="content">
      <?php if ($flashMessage): ?>
        <div class="alert <?= e($flashMessage['type']) ?>"><?= e($flashMessage['message']) ?></div>
      <?php endif; ?>
