import { contextBridge as o, ipcRenderer as e } from "electron";
o.exposeInMainWorld("electronAPI", {
  readStore: () => e.invoke("read-store"),
  writeStore: (r) => e.invoke("write-store", r)
});
