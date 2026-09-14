(() => {
  const UPDATE_NOTICE_KEY = 'mushavo-pwa-update-complete';
  const supportsServiceWorker = Boolean(navigator.serviceWorker);
  const hadController = Boolean(navigator.serviceWorker?.controller);
  const isStandalone = window.matchMedia?.('(display-mode: standalone)').matches
    || window.navigator.standalone === true;
  const isIos = /iphone|ipad|ipod/i.test(window.navigator.userAgent)
    || (window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1);
  let isRefreshing = false;
  let deferredInstallPrompt = null;
  let installBanner = null;

  const notificationPermissionState = () => {
    if (isIos && !isStandalone) {
      return {
        buttonLabel: 'Install app first',
        disabled: true,
        status: 'On iPhone or iPad, add Mushavo Homes to your Home Screen before enabling notifications.'
      };
    }

    if (!('Notification' in window) || !('PushManager' in window) || !supportsServiceWorker) {
      return {
        buttonLabel: 'Not supported',
        disabled: true,
        status: 'This browser does not support Mushavo Homes push notifications.'
      };
    }

    if (!window.isSecureContext) {
      return {
        buttonLabel: 'Secure connection required',
        disabled: true,
        status: 'Notifications are available only through the secure Mushavo Homes website.'
      };
    }

    if (Notification.permission === 'granted') {
      return {
        buttonLabel: 'Notifications enabled',
        disabled: true,
        status: 'Notifications are enabled on this device.'
      };
    }

    if (Notification.permission === 'denied') {
      return {
        buttonLabel: 'Notifications blocked',
        disabled: true,
        status: 'Notifications are blocked in this browser. You can enable them later in the site settings.'
      };
    }

    return {
      buttonLabel: 'Enable notifications',
      disabled: false,
      status: 'Choose Enable notifications when you are ready. Mushavo Homes will then ask for browser permission.'
    };
  };

  const syncNotificationPermissionUi = (root = document) => {
    const state = notificationPermissionState();
    const selector = '[data-mushavo-notification-permission]';
    const panels = [
      ...(root.matches?.(selector) ? [root] : []),
      ...(root.querySelectorAll?.(selector) || [])
    ];
    panels.forEach((panel) => {
      const button = panel.querySelector('[data-mushavo-enable-notifications]');
      const status = panel.querySelector('[data-mushavo-notification-status]');
      if (button) {
        button.textContent = state.buttonLabel;
        button.disabled = state.disabled;
      }
      if (status) status.textContent = state.status;
    });
    return state;
  };

  const continueToPushSubscription = () => {
    document.dispatchEvent(new CustomEvent('mushavo:pwa-notification-permission-granted'));
  };

  const requestNotificationPermission = async (panel) => {
    if (!('Notification' in window)) {
      syncNotificationPermissionUi(panel || document);
      return 'unsupported';
    }

    const beforeRequest = notificationPermissionState();
    if (beforeRequest.disabled) {
      syncNotificationPermissionUi(panel || document);
      if (Notification.permission === 'granted') continueToPushSubscription();
      return Notification.permission;
    }

    const button = panel?.querySelector('[data-mushavo-enable-notifications]');
    const status = panel?.querySelector('[data-mushavo-notification-status]');
    if (button) {
      button.disabled = true;
      button.textContent = 'Waiting for permission...';
    }
    if (status) status.textContent = 'Use the browser prompt to allow or block notifications.';

    try {
      const permission = await Notification.requestPermission();
      syncNotificationPermissionUi(document);
      if (permission === 'granted') continueToPushSubscription();
      return permission;
    } catch (error) {
      if (status) status.textContent = 'The permission request could not be completed. The rest of Mushavo Homes is still available.';
      if (button) {
        button.disabled = false;
        button.textContent = 'Try again';
      }
      return 'error';
    }
  };

  const mountNotificationPermission = (host) => {
    if (!host || host.dataset.mushavoNotificationMounted === 'true') return;
    host.dataset.mushavoNotificationMounted = 'true';
    host.setAttribute('data-mushavo-notification-permission', '');

    host.innerHTML = `
      <section class="rounded-xl border border-emerald-200 bg-emerald-50/70 p-4 shadow-soft sm:p-5" aria-labelledby="mushavo-push-title">
        <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div class="min-w-0">
            <h2 id="mushavo-push-title" class="text-base font-bold text-slate-900">Stay updated with Mushavo Homes</h2>
            <p class="mt-1 text-sm leading-6 text-slate-600">Receive important updates on this device, even when the app is not open.</p>
            <ul class="mt-3 grid gap-x-5 gap-y-1 text-sm font-medium text-slate-700 sm:grid-cols-2">
              <li>✓ Payment reminders</li>
              <li>✓ Payment confirmations</li>
              <li>✓ Maintenance updates</li>
              <li>✓ Lease reminders</li>
            </ul>
          </div>
          <div class="shrink-0 lg:max-w-xs">
            <button data-mushavo-enable-notifications type="button" class="min-h-11 w-full rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700 disabled:cursor-default disabled:bg-slate-300 disabled:text-slate-600 lg:w-auto">Enable notifications</button>
            <p data-mushavo-notification-status class="mt-2 max-w-sm text-xs leading-5 text-slate-600" role="status" aria-live="polite"></p>
          </div>
        </div>
      </section>`;

    host.querySelector('[data-mushavo-enable-notifications]')?.addEventListener(
      'click',
      () => requestNotificationPermission(host)
    );
    syncNotificationPermissionUi(host);
  };

  window.MushavoPwaNotifications = {
    mount: mountNotificationPermission,
    requestPermission: requestNotificationPermission,
    sync: syncNotificationPermissionUi
  };

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

  if (supportsServiceWorker) {
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
  }

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

    syncNotificationPermissionUi();

    if (supportsServiceWorker) {
      navigator.serviceWorker.register('/sw.js', {
        scope: '/',
        updateViaCache: 'none'
      })
        .then((registration) => registration.update())
        .catch((error) => {
          console.error('Mushavo Homes service worker registration failed.', error);
        });
    }
  }, { once: true });
})();
