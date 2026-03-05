"use strict";
const electron = require("electron");
electron.contextBridge.exposeInMainWorld("electronAPI", {
  readStore: () => electron.ipcRenderer.invoke("read-store"),
  writeStore: (data) => electron.ipcRenderer.invoke("write-store", data)
});
