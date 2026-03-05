import { contextBridge, ipcRenderer } from 'electron';

// Expose safe, bounded IPC channels to the renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  readStore: (): Promise<string | null> => ipcRenderer.invoke('read-store'),
  writeStore: (data: string): Promise<boolean> => ipcRenderer.invoke('write-store', data),
});
