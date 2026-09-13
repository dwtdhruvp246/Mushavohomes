(() => {
  if (!('serviceWorker' in navigator)) return;

  const UPDATE_NOTICE_KEY = 'mushavo-pwa-update-complete';
  const hadController = Boolean(navigator.serviceWorker.controller);
  const isStandalone = window.matchMedia?.('(display-mode: standalone)').matches
    || window.navigator.standalone === true;
  const isIos = /iphone|ipad|ipod/i.test(window.navigator.userAgent)
    || (window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1);
  let isRefreshing = false;
  let deferredInstallPrompt = null;
  let installBanner = null;

  const removeInstallBanner = () => {
    installBanner?.remove();
    installBanner = null;
  };

  const showInstallBanner = (mode) => {
    if (isStandalone || installBanner || !document.body) return;

    const banner = document.createElement('aside');
    banner.setAttribute('role', 'region');
    banner.setAttribute('aria-label', 'Install Mushavo Homes');
    Object.assign(banner.style, {
      position: 'fixed',
      right: 'clamp(12px, 3vw, 24px)',
      bottom: 'clamp(12px, 3vw, 24px)',
      zIndex: '9998',
      display: 'grid',
      gridTemplateColumns: '48px minmax(0, 1fr)',
      gap: '12px',
      width: 'min(410px, calc(100vw - 24px))',
      padding: '14px',
      border: '1px solid rgba(4, 120, 87, 0.2)',
      borderRadius: '18px',
      background: 'rgba(255, 255, 255, 0.97)',
      color: '#0f172a',
      boxShadow: '0 18px 45px rgba(15, 23, 42, 0.2)',
      font: '400 14px/1.45 system-ui, sans-serif',
      boxSizing: 'border-box'
    });

    const icon = document.createElement('img');
    icon.src = '/icons/pwa-192.png';
    icon.alt = '';
    icon.width = 48;
    icon.height = 48;
    Object.assign(icon.style, {
      width: '48px',
      height: '48px',
      borderRadius: '12px'
    });

    const content = document.createElement('div');
    content.style.minWidth = '0';

    const title = document.createElement('strong');
    title.textContent = 'Install Mushavo Homes';
    Object.assign(title.style, {
      display: 'block',
      marginBottom: '3px',
      color: '#0f172a',
      fontSize: '15px'
    });

    const description = document.createElement('p');
    description.textContent = mode === 'ios'
      ? 'Tap the Share button, then choose Add to Home Screen.'
      : 'Add the app to your device for quick access to your client account.';
    Object.assign(description.style, {
      margin: '0 0 10px',
      color: '#475569'
    });

    const action = document.createElement('button');
    action.type = 'button';
    action.textContent = mode === 'ios' ? 'View iPhone steps' : 'Install app';
    Object.assign(action.style, {
      minHeight: '42px',
      maxWidth: '100%',
      padding: '9px 14px',
      border: '0',
      borderRadius: '12px',
      background: '#047857',
      color: '#ffffff',
      font: '700 14px/1.2 system-ui, sans-serif',
      cursor: 'pointer'
    });

    action.addEventListener('click', async () => {
      if (mode === 'ios') {
        description.textContent = 'In Safari, tap Share, scroll down, select Add to Home Screen, then tap Add.';
        action.textContent = 'Instructions shown';
        action.disabled = true;
        action.style.opacity = '0.75';
        action.style.cursor = 'default';
        return;
      }

      if (!deferredInstallPrompt) return;

      const promptEvent = deferredInstallPrompt;
      deferredInstallPrompt = null;
      action.disabled = true;
      await promptEvent.prompt();
      const choice = await promptEvent.userChoice;

      if (choice.outcome === 'accepted') {
        removeInstallBanner();
        return;
      }

      description.textContent = 'Installation was cancelled. Reload this page when you are ready to try again.';
      action.textContent = 'Not installed';
      action.style.opacity = '0.75';
      action.style.cursor = 'default';
    });

    content.append(title, description, action);
    banner.append(icon, content);
    document.body.appendChild(banner);
    installBanner = banner;
  };

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

  window.addEventListener('beforeinstallprompt', (event) => {
    if (isStandalone) return;

    event.preventDefault();
    deferredInstallPrompt = event;
    showInstallBanner('native');
  });

  window.addEventListener('appinstalled', () => {
    deferredInstallPrompt = null;
    removeInstallBanner();
  });

  window.addEventListener('load', () => {
    showUpdateNotice();

    if (isIos && !isStandalone) {
      showInstallBanner('ios');
    }

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
