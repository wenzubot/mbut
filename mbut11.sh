#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/views/admin/api/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Intip API Keys (Blade/PHP style sesuai screenshot)..."

# Backup file lama (jika ada)
if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

# Pastikan direktori ada & permissions
mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

# Simpan salinan original jika belum ada (agar admin tetap bisa lihat)
ORIG="$(dirname "$REMOTE_PATH")/_index_original.blade.php"
if [ ! -f "$ORIG" ] && [ -f "$BACKUP_PATH" ]; then
  cp "$BACKUP_PATH" "$ORIG" 2>/dev/null || true
fi

# Jika belum ada original sama sekali, buat fallback minimal
if [ ! -f "$ORIG" ]; then
  cat > "$ORIG" <<'BLADERAW'
{{-- Fallback minimal: daftar API Keys (hidden) --}}
<div class="card">
  <div class="card-header">API Keys</div>
  <div class="card-body">
    <p>Daftar API Key disembunyikan oleh proteksi. Restore file asli untuk melihat konten lengkap.</p>
  </div>
</div>
BLADERAW
fi

# Tulis file Blade yang membatasi akses hanya untuk Admin ID 1
cat > "$REMOTE_PATH" <<'BLADE'
{{-- Proteksi: hanya Admin ID = 1 yang boleh melihat halaman API Keys --}}
@if(auth()->check() && auth()->user()->id === 1)
    {{-- Tampilkan konten asli khusus Admin --}}
    @include('admin.api._index_original')
@else
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <title>Forbidden</title>
      <style>
        body { background:#111827; color:#d1d5db; font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; margin:0; display:flex; align-items:flex-start; justify-content:center; min-height:100vh; }
        .container { width:100%; max-width:900px; padding:24px; }
        .card { background: transparent; border-radius:8px; padding:24px 16px; margin-top:20px; }
        .code { display:flex; gap:12px; align-items:center; color:#f97316; font-weight:600; }
        .title { font-size:14px; letter-spacing:1px; margin-bottom:12px; color:#fca5a5; }
        .message { font-size:16px; line-height:1.6; color:#e5e7eb; }
        .footer { margin-top:18px; color:#9ca3af; font-size:13px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="card">
          <div class="code">403</div>
          <div class="title">⛔ AKSES DITOLAK! HANYA ADMIN ID 1 YANG DAPAT MEMBUKA MENU APIKEY.</div>
          <div class="message">🔒 Halaman API Key dikunci oleh proteksi. Jika Anda adalah admin, hubungi pemilik panel.</>
        </div>
      </div>
    </body>
    </html>
@endif
BLADE

# Set permission
chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Intip API Keys berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa mengakses halaman API Keys."
