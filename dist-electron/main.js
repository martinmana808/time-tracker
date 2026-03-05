import { app as r, BrowserWindow as h, ipcMain as c, nativeImage as w, Tray as u } from "electron";
import i from "path";
import s from "fs";
let l = null, e = null;
const p = process.env.NODE_ENV === "development", m = () => {
  const t = w.createFromPath(i.join(__dirname, "../public/vite.svg")).resize({ width: 16, height: 16 });
  l = new u(t), l.setToolTip("Harvest Clone"), l.on("click", (o, n) => {
    g(n);
  });
}, d = () => {
  e = new h({
    width: 380,
    height: 600,
    show: !1,
    frame: !1,
    fullscreenable: !1,
    resizable: !1,
    transparent: !0,
    webPreferences: {
      preload: i.join(__dirname, "preload.js"),
      nodeIntegration: !1,
      contextIsolation: !0
    }
  }), p ? e.loadURL("http://localhost:5173") : e.loadFile(i.join(__dirname, "../dist/index.html")), e.on("blur", () => {
    e?.webContents.isDevToolsOpened() || e?.hide();
  });
}, g = (t) => {
  if (e)
    if (e.isVisible())
      e.hide();
    else {
      const o = e.getBounds(), n = Math.round(t.x + t.width / 2 - o.width / 2), a = Math.round(t.y + t.height);
      e.setPosition(n, a, !1), e.show(), e.focus();
    }
}, v = () => {
  const t = r.getPath("userData"), o = i.join(t, "harvest-clone-data.json");
  c.handle("read-store", () => {
    try {
      if (s.existsSync(o))
        return s.readFileSync(o, "utf-8");
    } catch (n) {
      console.error("Error reading store:", n);
    }
    return null;
  }), c.handle("write-store", (n, a) => {
    try {
      return s.writeFileSync(o, a, "utf-8"), !0;
    } catch (f) {
      return console.error("Error writing store:", f), !1;
    }
  });
};
r.whenReady().then(() => {
  r.dock && r.dock.hide(), v(), d(), m(), r.on("activate", () => {
    h.getAllWindows().length === 0 && d();
  });
});
r.on("window-all-closed", () => {
  process.platform !== "darwin" && r.quit();
});
