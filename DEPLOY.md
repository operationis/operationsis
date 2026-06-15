# Deploying the Bayut KSA Sales Operations Dashboard

The dashboard is a **single-file HTML application** (`index.html`) plus a `Data Source/` folder of CSV files. There is no build step, no Node, no backend. You upload the files to any static web host and the dashboard works.

## What to upload

```
/  (your web root, or any sub-folder)
├── index.html                ← the entire dashboard
├── data-manifest.json        ← lists which CSVs to fetch
├── Data Source/              ← drop your CSVs here
│   ├── Sales Tracker.csv
│   ├── Documentation Tracker.csv
│   ├── Sadq Tracker.csv
│   ├── Payments Tracker.csv
│   ├── Recovery Workflow Tracker.csv
│   ├── Off Plan Project Workflow Tracker.csv
│   ├── Ready Project Workflow Tracker.csv
│   ├── Recovery Tracker.csv
│   ├── IS CS Tracker.csv
│   ├── Hotline Agent Summary Tracker.csv
│   ├── Hotline Call Center Tracker.csv
│   └── Hotline SLA Tracker.csv
└── rebuild-manifest.ps1      ← optional helper (Windows only)
```

That's everything. No `node_modules`, no `package.json`, no compile step.

## How it works on the web

When `index.html` loads from a server (HTTP / HTTPS), it:

1. Fetches `data-manifest.json` from the same folder.
2. Reads the `files` array and fetches each CSV from `Data Source/<filename>` in parallel.
3. Routes each CSV into the correct dashboard section by filename + header signature.
4. Renders every panel — KPIs, charts, tables — from the loaded data.

The **Refresh** button in the header re-fetches the same files, so updating a CSV on the server + clicking Refresh shows the new numbers without a full page reload.

## Updating the data

1. Replace one or more CSVs inside `Data Source/`.
2. If you **add a new file** or **rename** one, regenerate the manifest:
   - Windows PowerShell: `.\rebuild-manifest.ps1`
   - Manually: open `data-manifest.json` and edit the `files` array.
3. Re-upload the changed files (no need to re-upload `index.html` unless you changed dashboard code).
4. Click **Refresh** on a loaded dashboard, or hard-reload (Ctrl/Cmd-Shift-R).

## Hosting options that work out of the box

Any host that serves static files works. Tested patterns:

- **Internal IIS / Apache / Nginx**: drop the folder into the document root or a virtual directory.
- **GitHub Pages**: push the folder to a `gh-pages` branch (or `main`/docs).
- **Netlify / Vercel / Cloudflare Pages**: drag-and-drop the folder; no build command needed.
- **AWS S3 + CloudFront**: enable static website hosting on the bucket, upload as a flat folder.
- **Azure Static Web Apps / Storage Account**: upload as static content.
- **Local network share served via IIS**: works exactly the same.

## Access control (optional but recommended)

The dashboard exposes raw business data — **publish it behind authentication.** Easiest options:

- **Internal hosting**: serve from a server behind the corporate VPN / SSO.
- **Netlify / Vercel / Cloudflare**: enable Basic Auth or Access policies in the dashboard settings.
- **Azure / AWS**: front the bucket with Cloudflare Access / Azure AD authentication.

## Caching

The autoloader appends `?t=<timestamp>` to every fetch so the browser never serves a stale CSV. You don't need to fiddle with cache headers.

## File:// fallback (running locally without a server)

If you double-click `index.html` to open it directly, browsers block `fetch()` of local files. In that case the dashboard:

1. Skips the autoloader silently.
2. Shows the **Connect Folder** button — click it to pick the local `Data Source/` folder via the File System Access API (Chrome / Edge) or a folder-upload picker (Firefox / Safari).
3. Loads exactly the same way as on the web.

For everyday use we recommend serving the folder through a tiny local HTTP server, e.g.:

```powershell
# From inside the dashboard folder
python -m http.server 8080
# or
npx serve .
```

Then open <http://localhost:8080/>.

## Sensitive data

CSVs are served as static files. Anyone with the URL can read them. **Always put authentication in front of the deployment** for any non-public data.
