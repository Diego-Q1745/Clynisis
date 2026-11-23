document.addEventListener('DOMContentLoaded', () => {
  const sidebar = document.getElementById('sidebar');
  const toggle = document.getElementById('menuToggle');
  if (toggle && sidebar) toggle.addEventListener('click', () => sidebar.classList.toggle('open'));

  document.querySelectorAll('[data-confirm]').forEach(link => {
    link.addEventListener('click', event => {
      if (!window.confirm(link.dataset.confirm || '¿Deseas continuar?')) event.preventDefault();
    });
  });

  document.querySelectorAll('[data-status-url]').forEach(select => {
    select.addEventListener('change', () => {
      if (!select.value) return;
      if (window.confirm('¿Confirmas el cambio de estado de esta cita?')) {
        window.location.href = select.dataset.statusUrl + encodeURIComponent(select.value);
      } else {
        select.value = '';
      }
    });
  });

  document.querySelectorAll('.alert').forEach(alert => {
    window.setTimeout(() => alert.classList.add('alert-hide'), 5000);
  });
});
