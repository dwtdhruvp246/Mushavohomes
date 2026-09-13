(() => {
  if (!('serviceWorker' in navigator)) return;

  const UPDATE_NOTICE_KEY = 'mushavo-pwa-update-complete';
  const hadController = Boolean(navigator.serviceWorker.controller);
  let isRefreshing = false;

  const showUpdateNotice = () => {
    try {
      if (window.sessionStorage.getItem(UPDATE_NOTICE_KEY) !== 'true') return;
      window.sessionStorage.removeItem(UPDATE_NOTICE_KEY);
    } catch (error) {
      return;
    }

    const notice = document.createElement('div');
    notice.setAttribute('role', 'status');
    notice.textContent = 'Mushavo Homes updated automatically.';
    Object.assign(notice.style, {
      position: 'fixed',
      right: '16px',
      bottom: '16px',
      zIndex: '9999',
      maxWidth: 'calc(100vw - 32px)',
      padding: '12px 16px',
      borderRadius: '14px',
      background: '#047857',
      color: '#ffffff',
      boxShadow: '0 12px 30px rgba(15, 23, 42, 0.2)',
      font: '600 14px/1.4 system-ui, sans-serif'
    });
    document.body.appendChild(notice);
    window.setTimeout(() => notice.remove(), 8000);
  };

  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (!hadController || isRefreshing) return;

    isRefreshing = true;
    try {
      window.sessionStorage.setItem(UPDATE_NOTICE_KEY, 'true');
    } catch (error) {
      // The update still completes if session storage is unavailable.
    }
    window.location.reload();
  });

  window.addEventListener('load', () => {
    showUpdateNotice();

    navigator.serviceWorker.register('/sw.js', {
      scope: '/',
      updateViaCache: 'none'
    })
      .then((registration) => registration.update())
      .catch((error) => {
        console.error('Mushavo Homes service worker registration failed.', error);
      });
  }, { once: true });
})();
