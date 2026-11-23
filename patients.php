<?php
require __DIR__ . '/includes/bootstrap.php';
$pageTitle='Pacientes'; $active='patients';

if ($_SERVER['REQUEST_METHOD']==='POST') {
    verify_csrf();
    $id=(int)($_POST['id_paciente']??0);
    $data=[
        trim($_POST['tipo_documento']??'DNI'), trim($_POST['numero_documento']??''),
        trim($_POST['nombres']??''), trim($_POST['apellidos']??''),
        $_POST['fecha_nacimiento']??'', $_POST['sexo']??'NO_ESPECIFICA',
        trim($_POST['telefono']??''), trim($_POST['correo']??''),
        trim($_POST['direccion']??''), $_POST['estado']??'ACTIVO'
    ];
    if ($data[1]==='' || $data[2]==='' || $data[3]==='' || $data[4]==='') {
        flash('error','Completa documento, nombres, apellidos y fecha de nacimiento.'); redirect('patients.php');
    }
    try {
        if ($id) {
            $sql="UPDATE pacientes SET tipo_documento=?,numero_documento=?,nombres=?,apellidos=?,fecha_nacimiento=?,sexo=?,telefono=?,correo=?,direccion=?,estado=? WHERE id_paciente=?";
            $data[]=$id; $pdo->prepare($sql)->execute($data); flash('success','Paciente actualizado correctamente.');
        } else {
            $sql="INSERT INTO pacientes (tipo_documento,numero_documento,nombres,apellidos,fecha_nacimiento,sexo,telefono,correo,direccion,estado) VALUES (?,?,?,?,?,?,?,?,?,?)";
            $pdo->prepare($sql)->execute($data); flash('success','Paciente registrado correctamente.');
        }
    } catch(PDOException $ex) { flash('error','No se pudo guardar. Verifica que el documento no esté registrado previamente.'); }
    redirect('patients.php');
}
if (isset($_GET['toggle'])) {
    $id=(int)$_GET['toggle'];
    $stmt=$pdo->prepare("UPDATE pacientes SET estado=IF(estado='ACTIVO','INACTIVO','ACTIVO') WHERE id_paciente=?");
    $stmt->execute([$id]); flash('success','Estado del paciente actualizado.'); redirect('patients.php');
}
$search=trim($_GET['q']??'');
$sql="SELECT * FROM pacientes";
$params=[];
if($search!==''){ $sql.=" WHERE nombres LIKE ? OR apellidos LIKE ? OR numero_documento LIKE ?"; $like="%$search%"; $params=[$like,$like,$like];}
$sql.=" ORDER BY id_paciente DESC";
$stmt=$pdo->prepare($sql); $stmt->execute($params); $rows=$stmt->fetchAll();
$edit=null;
if(isset($_GET['edit'])){$stmt=$pdo->prepare("SELECT * FROM pacientes WHERE id_paciente=?");$stmt->execute([(int)$_GET['edit']]);$edit=$stmt->fetch();}
$showForm=isset($_GET['action'])&&$_GET['action']==='create'||$edit;
require __DIR__.'/includes/header.php';
?>
<div class="page-heading"><div><div class="eyebrow">GESTIÓN DE PERSONAS</div><h1>Pacientes</h1><p>Registra y administra la información de los pacientes.</p></div><a class="btn btn-primary" href="patients.php?action=create">＋ Nuevo paciente</a></div>
<?php if($showForm): $v=$edit?:[]; ?>
<section class="panel form-panel"><div class="panel-heading"><div><h3><?= $edit?'Editar paciente':'Registrar paciente' ?></h3><p>Los campos marcados con * son obligatorios.</p></div><a class="text-link" href="patients.php">✕ Cerrar</a></div>
<form method="post" class="form-grid"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="id_paciente" value="<?= (int)($v['id_paciente']??0) ?>">
<label>Tipo de documento *<select name="tipo_documento"><option>DNI</option><option <?= ($v['tipo_documento']??'')==='CE'?'selected':'' ?>>CE</option><option <?= ($v['tipo_documento']??'')==='PASAPORTE'?'selected':'' ?>>PASAPORTE</option></select></label>
<label>Número de documento *<input name="numero_documento" required maxlength="20" value="<?= e($v['numero_documento']??'') ?>"></label>
<label>Nombres *<input name="nombres" required value="<?= e($v['nombres']??'') ?>"></label>
<label>Apellidos *<input name="apellidos" required value="<?= e($v['apellidos']??'') ?>"></label>
<label>Fecha de nacimiento *<input type="date" name="fecha_nacimiento" required value="<?= e($v['fecha_nacimiento']??'') ?>"></label>
<label>Sexo<select name="sexo"><?php foreach(['F'=>'Femenino','M'=>'Masculino','OTRO'=>'Otro','NO_ESPECIFICA'=>'No especifica'] as $k=>$label): ?><option value="<?= $k ?>" <?= ($v['sexo']??'NO_ESPECIFICA')===$k?'selected':'' ?>><?= $label ?></option><?php endforeach; ?></select></label>
<label>Teléfono<input name="telefono" value="<?= e($v['telefono']??'') ?>"></label>
<label>Correo electrónico<input type="email" name="correo" value="<?= e($v['correo']??'') ?>"></label>
<label class="span-2">Dirección<input name="direccion" value="<?= e($v['direccion']??'') ?>"></label>
<label>Estado<select name="estado"><option value="ACTIVO">Activo</option><option value="INACTIVO" <?= ($v['estado']??'')==='INACTIVO'?'selected':'' ?>>Inactivo</option></select></label>
<div class="form-actions span-2"><a class="btn btn-outline" href="patients.php">Cancelar</a><button class="btn btn-primary" type="submit">Guardar paciente</button></div></form></section>
<?php endif; ?>
<section class="panel"><div class="panel-heading"><div><h3>Listado de pacientes</h3><p><?= count($rows) ?> registro(s) encontrados</p></div><form class="search-form"><input name="q" placeholder="Buscar por nombre o documento..." value="<?= e($search) ?>"><button class="btn btn-outline">Buscar</button></form></div>
<div class="table-wrap"><table><thead><tr><th>PACIENTE</th><th>DOCUMENTO</th><th>CONTACTO</th><th>REGISTRO</th><th>ESTADO</th><th>ACCIONES</th></tr></thead><tbody>
<?php foreach($rows as $r): ?><tr><td><strong><?= e($r['nombres'].' '.$r['apellidos']) ?></strong><small class="sub-cell">ID #<?= (int)$r['id_paciente'] ?></small></td><td><?= e($r['tipo_documento'].' '.$r['numero_documento']) ?></td><td><?= e($r['telefono']?:'—') ?><small class="sub-cell"><?= e($r['correo']?:'') ?></small></td><td><?= date('d/m/Y',strtotime($r['fecha_registro'])) ?></td><td><span class="badge <?= status_class($r['estado']) ?>"><?= e($r['estado']) ?></span></td><td class="actions"><a href="patients.php?edit=<?= (int)$r['id_paciente'] ?>">Editar</a><a href="patients.php?toggle=<?= (int)$r['id_paciente'] ?>" data-confirm="¿Cambiar el estado de este paciente?"><?= $r['estado']==='ACTIVO'?'Desactivar':'Activar' ?></a></td></tr><?php endforeach; ?>
<?php if(!$rows): ?><tr><td colspan="6"><div class="empty-state compact">No se encontraron pacientes.</div></td></tr><?php endif; ?>
</tbody></table></div></section>
<?php require __DIR__.'/includes/footer.php'; ?>
