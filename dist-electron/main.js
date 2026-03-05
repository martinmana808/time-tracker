"use strict";
const electron = require("electron");
const path = require("path");
const fs = require("fs");
let tray = null;
let window = null;
const isDev = process.env.NODE_ENV === "development";
const createTray = () => {
  const icon = electron.nativeImage.createFromPath(path.join(__dirname, "../public/vite.svg")).resize({ width: 16, height: 16 });
  tray = new electron.Tray(icon);
  tray.setToolTip("Harvest Clone");
  tray.on("click", (event, bounds) => {
    toggleWindow(bounds);
  });
};
const createWindow = () => {
  window = new electron.BrowserWindow({
    width: 380,
    height: 600,
    show: false,
    frame: false,
    fullscreenable: false,
    resizable: false,
    transparent: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  if (isDev) {
    window.loadURL("http://localhost:5173");
  } else {
    window.loadFile(path.join(__dirname, "../dist/index.html"));
  }
  window.on("blur", () => {
    if (!window?.webContents.isDevToolsOpened()) {
      window?.hide();
    }
  });
};
const toggleWindow = (bounds) => {
  if (!window) return;
  if (window.isVisible()) {
    window.hide();
  } else {
    const windowBounds = window.getBounds();
    const x = Math.round(bounds.x + bounds.width / 2 - windowBounds.width / 2);
    const y = Math.round(bounds.y + bounds.height);
    window.setPosition(x, y, false);
    window.show();
    window.focus();
  }
};
const setupDataStore = () => {
  const userDataPath = electron.app.getPath("userData");
  const dataPath = path.join(userDataPath, "harvest-clone-data.json");
  electron.ipcMain.handle("read-store", () => {
    try {
      if (fs.existsSync(dataPath)) {
        return fs.readFileSync(dataPath, "utf-8");
      }
    } catch (err) {
      console.error("Error reading store:", err);
    }
    return null;
  });
  electron.ipcMain.handle("write-store", (_, data) => {
    try {
      fs.writeFileSync(dataPath, data, "utf-8");
      return true;
    } catch (err) {
      console.error("Error writing store:", err);
      return false;
    }
  });
};
electron.app.whenReady().then(() => {
  if (electron.app.dock) {
    electron.app.dock.hide();
  }
  setupDataStore();
  createWindow();
  createTray();
  electron.app.on("activate", () => {
    if (electron.BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});
electron.app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    electron.app.quit();
  }
});
