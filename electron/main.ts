// eslint-disable-next-line import/no-extraneous-dependencies
import {
  app, BrowserWindow, ipcMain, shell, globalShortcut,
} from 'electron';
import { Menubar, menubar } from 'menubar';
import path from 'path';
import { appConfig } from './config';
import { validateWebContentsInputEvent } from './keyboard-shortcuts';
import { fetchAppSettingsFromFile, writeAppSettingsToFile } from './settings';
import { initTranslateWindow } from './translate-window';
import { AppSettings } from './types';
import { isDev } from './utils';

declare const MAIN_WINDOW_WEBPACK_ENTRY: string;
declare const MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY: string;

let menuBar: Menubar;
let translateWindow: BrowserWindow;
let settingsVisible : boolean;
let currentAppSettings: AppSettings;

const assetsPath = process.env.NODE_ENV === 'production'
  ? path.join(process.resourcesPath, 'assets')
  : path.join(app.getAppPath(), 'assets');

function applyLocalKeyboardShortcuts() {
  if (isDev()) {
    console.info('Configuring local key listeners');
  }

  fetchAppSettingsFromFile()
    .then((settings: AppSettings) => {
      if (!menuBar.window) {
        throw new Error('Menubar BrowserWindow not properly initialized!');
      }

      menuBar.window.webContents.on('before-input-event', (event, input) => {
        validateWebContentsInputEvent(event, input, menuBar, translateWindow, settings.keyBindings);
      });
      translateWindow.webContents.on('before-input-event', (event, input) => {
        validateWebContentsInputEvent(event, input, menuBar, translateWindow, settings.keyBindings);
      });
    });
}

function registerSettings() {
  fetchAppSettingsFromFile()
    .then((settings) => {
      if (!menuBar.window) {
        throw new Error('Could not register settings: MenuBar BrowserWindow not found!');
      }

      currentAppSettings = settings;
      menuBar.window.webContents.send('setSettings', settings);
    });
}

function registerListeners() {
  /**
   * This comes from bridge integration, check bridge.ts
   */
  ipcMain.on('message', (_, message: string) => {
    // eslint-disable-next-line no-console
    console.log(message);
  });

  ipcMain.on('shutdown', () => {
    app.quit();
  });

  ipcMain.on('showSettings', (_, show: boolean) => {
    if (show) {
      settingsVisible = true;
      translateWindow.hide();
    } else {
      settingsVisible = false;
      translateWindow.show();
    }
  });

  ipcMain.on('writeSettingsToFile', async (_, appSettings: AppSettings) => {
    currentAppSettings = appSettings;
    await writeAppSettingsToFile(appSettings);
    applyLocalKeyboardShortcuts();
  });

  ipcMain.on('sponsor', () => {
    shell.openExternal('https://paypal.me/thijmendam');
  });
}

function createMenubarApp() {
  menuBar = menubar({
    icon: path.join(assetsPath, '/BarTranslateIcon.png').toString(),
    index: MAIN_WINDOW_WEBPACK_ENTRY,
    preloadWindow: true,
    browserWindow: {
      skipTaskbar: true,
      show: false,
      height: appConfig.height,
      width: appConfig.width,
      transparent: true,
      frame: false,
      resizable: isDev(),
      movable: false,
      fullscreenable: false,
      minimizable: false,
      alwaysOnTop: true,
      webPreferences: {
        devTools: isDev(),
        preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      },
      hasShadow: true,
    },
  });

  menuBar.on('ready', () => {
    setTimeout(() => {
      app.dock.hide();
    }, 1000);
    translateWindow = initTranslateWindow(menuBar);

    if (!menuBar.window) {
      throw new Error('Menubar BrowserWindow not properly initialized!');
    }

    menuBar.window.setMenu(null);

    registerListeners();
    registerShortcuts();
    registerSettings();

    menuBar.on('show', () => {
      if (!translateWindow.isVisible() && !settingsVisible) {
        if (currentAppSettings.autoscroll) {
          translateWindow.webContents.executeJavaScript('window.scrollTo(0, 0)');
        }

        // TODO: check if dark mode is enabled, and insert CSS accordingly
        // translateWindow.webContents.insertCSS(HideRedundantElementsCSS);

        translateWindow.show();
      }
    });

    menuBar.on('focus-lost', () => {
      if (!translateWindow.isFocused()) {
        translateWindow.hide();
        menuBar.hideWindow();
      }
    });
  });
}

function registerShortcuts() {
  // Global: show or hide app
  globalShortcut.register('Alt+K', () => {
    if (!menuBar.window?.isVisible()) {
      menuBar.showWindow();
    } else {
      menuBar.hideWindow();
    }
  });

  if (!menuBar.window) {
    throw new Error('Could not register input event because MenuBar BrowserWindow is not found!');
  }

  applyLocalKeyboardShortcuts();
}

app.on('ready', createMenubarApp)
  .whenReady()
  // eslint-disable-next-line no-console
  .catch((e) => console.error(e));

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMenubarApp();
  }
});
