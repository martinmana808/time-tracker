"use strict";const e=require("electron");e.contextBridge.exposeInMainWorld("electronAPI",{readStore:()=>e.ipcRenderer.invoke("read-store"),writeStore:r=>e.ipcRenderer.invoke("write-store",r)});
