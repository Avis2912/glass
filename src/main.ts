import { app, BrowserWindow, ipcMain, screen } from 'electron';
import * as path from 'path';

let mainWindow: BrowserWindow | null = null;
let notificationWindow: BrowserWindow | null = null;

function createMainWindow(): void {
  // Create the main window
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  // Load the main HTML file
  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function createNotificationWindow(text: string): void {
  // Get the primary display
  const primaryDisplay = screen.getPrimaryDisplay();
  const { width, height } = primaryDisplay.workAreaSize;

  // Position the notification in the bottom right corner
  const notificationWidth = 350;
  const notificationHeight = 80;
  const x = width - notificationWidth - 20;
  const y = height - notificationHeight - 40;

  // If there's an existing notification, close it first
  if (notificationWindow) {
    notificationWindow.close();
  }

  // Create the notification window
  notificationWindow = new BrowserWindow({
    width: notificationWidth,
    height: notificationHeight,
    x: x,
    y: y,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    movable: false,
    show: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  // Load the notification HTML
  notificationWindow.loadURL(`file://${path.join(__dirname, 'notification.html')}`);

  // Show the window when ready
  notificationWindow.once('ready-to-show', () => {
    notificationWindow?.show();
    notificationWindow?.webContents.send('show-notification', text);

    // Auto-hide after 3 seconds
    setTimeout(() => {
      if (notificationWindow) {
        notificationWindow.close();
        notificationWindow = null;
      }
    }, 3000);
  });

  notificationWindow.on('closed', () => {
    notificationWindow = null;
  });
}

app.whenReady().then(() => {
  createMainWindow();

  // Listen for text selection events
  ipcMain.on('show-notification', (event, text: string) => {
    createNotificationWindow(text);
  });

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

