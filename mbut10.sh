#!/bin/bash

TARGET_FILE="/var/www/pterodactyl/resources/views/templates/base/core.blade.php"
BACKUP_FILE="${TARGET_FILE}.bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"

echo "🚀 Mengganti isi $TARGET_FILE dengan popup dan marquee..."

# Backup dulu file lama
if [ -f "$TARGET_FILE" ]; then
  cp "$TARGET_FILE" "$BACKUP_FILE"
  echo "📦 Backup file lama dibuat di $BACKUP_FILE"
fi

cat > "$TARGET_FILE" << 'EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    <div id="modal-portal"></div>
    <div id="app"></div>

    <script>
      document.addEventListener("DOMContentLoaded", () => {
        const username = @json(auth()->user()->name?? 'User');

        // Popup sapaan
        const message = document.createElement("div");
        message.innerText = `Welcome ${username}, Di Panel Pterodactyl Milik Saya😎`;
        Object.assign(message.style, {
          position: "fixed",
          bottom: "20px",
          right: "20px",
          background: "rgba(0,0,0,0.75)",
          color: "#fff",
          padding: "10px 15px",
          borderRadius: "10px",
          fontFamily: "monospace",
          fontSize: "14px",
          boxShadow: "0 0 10px rgba(0,0,0,0.3)",
          zIndex: "9999",
          opacity: "1",
          transition: "opacity 1s ease"
        });
        document.body.appendChild(message);
        setTimeout(() => message.style.opacity = "0", 3000);
        setTimeout(() => message.remove(), 4000);

        // Tulisan berjalan (marquee)
        const marqueeContainer = document.createElement("div");
        marqueeContainer.style = "width: 100%; overflow: hidden; white-space: nowrap; background: #222; color: #eee; padding: 10px 0; position: fixed; top: 0; left: 0; z-index: 9998; font-family: monospace;";
        const marquee = document.createElement("span");
        marquee.innerText = `Welcome ${username}, Di Panel Pterodactyl Milik Saya😎`;
        marquee.style.display = "inline-block";
        marquee.style.paddingLeft = "100%";
        marquee.style.animation = "marquee 15s linear infinite";
        marqueeContainer.appendChild(marquee);
        document.body.appendChild(marqueeContainer);
      });
    </script>

    <style>
      @keyframes marquee {
        0% {
          transform: translateX(0%);
        }
        100% {
          transform: translateX(-100%);
        }
      }
    </style>
@endsection
EOF

echo "✅ Isi $TARGET_FILE sudah diganti dengan popup dan tulisan berjalan."
