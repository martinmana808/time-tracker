import { app, BrowserWindow, Tray, ipcMain, nativeImage } from 'electron';
import path from 'path';
import fs from 'fs';

let tray: Tray | null = null;
let window: BrowserWindow | null = null;

// Determine environment
const isDev = process.env.NODE_ENV === 'development';

const createTray = () => {
  // Use a generic icon or empty for now (a dot)
  // In production, you would load a real `.icns` or `.png` here.
  const icon = nativeImage.createFromPath(path.join(__dirname, '../public/vite.svg')).resize({ width: 16, height: 16 });
  tray = new Tray(icon);
  
  tray.setToolTip('Harvest Clone');
  
  tray.on('click', (event, bounds) => {
    toggleWindow(bounds);
  });
};

const createWindow = () => {
  window = new BrowserWindow({
    width: 380,
    height: 600,
    show: false,
    frame: false,
    fullscreenable: false,
    resizable: false,
    transparent: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  if (isDev) {
    window.loadURL('http://localhost:5173');
  } else {
    window.loadFile(path.join(__dirname, '../dist/index.html'));
  }

  // Hide the window when it loses focus (clicked away)
  window.on('blur', () => {
    if (!window?.webContents.isDevToolsOpened()) {
      window?.hide();
    }
  });
};

const toggleWindow = (bounds: Electron.Rectangle) => {
  if (!window) return;

  if (window.isVisible()) {
    window.hide();
  } else {
    // Calculate the position to be right below the tray icon
    const windowBounds = window.getBounds();
    const x = Math.round(bounds.x + (bounds.width / 2) - (windowBounds.width / 2));
    const y = Math.round(bounds.y + bounds.height);
    
    window.setPosition(x, y, false);
    window.show();
    window.focus();
  }
};

// Set up robust file-system data store
const setupDataStore = () => {
  const userDataPath = app.getPath('userData');
  const dataPath = path.join(userDataPath, 'harvest-clone-data.json');

  ipcMain.handle('read-store', () => {
    try {
      if (fs.existsSync(dataPath)) {
        return fs.readFileSync(dataPath, 'utf-8');
      }
    } catch (err) {
      console.error('Error reading store:', err);
    }
    return null;
  });

  ipcMain.handle('write-store', (_, data: string) => {
    try {
      fs.writeFileSync(dataPath, data, 'utf-8');
      return true;
    } catch (err) {
      console.error('Error writing store:', err);
      return false;
    }
  });
};

app.whenReady().then(() => {
  // Hide from the standard dock
  if (app.dock) {
    app.dock.hide();
  }

  setupDataStore();
  createWindow();
  createTray();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
