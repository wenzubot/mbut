#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi tampilan Server List (Anti Lihat Server)..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
@extends('layouts.admin')

@section('title')
    Server Management
@endsection

@section('content-header')
    <h1>Daftar Server</h1>
@endsection

@section('content')
@php
    use Illuminate\Support\Facades\Auth;
    \$user = Auth::user();
@endphp

<div class="card">
    <div class="card-body">

        @if(\$user->id !== 1)
            <div class="alert alert-danger text-center" style="font-weight:bold;">
                ❌ Akses Ditolak<br>
                Anda hanya dapat melihat server milik Anda sendiri.
            </div>

            {{-- Hanya tampilkan server milik user --}}
            @php
                \$servers = \\Pterodactyl\\Models\\Server::where('owner_id', \$user->id)
                    ->orWhere('user_id', \$user->id)
                    ->get();
            @endphp
        @else
            {{-- Admin (ID 1) dapat melihat semua server --}}
            @php
                \$servers = \\Pterodactyl\\Models\\Server::all();
            @endphp
        @endif

        <table class="table table-hover table-bordered">
            <thead class="thead-dark">
                <tr>
                    <th>ID</th>
                    <th>Nama Server</th>
                    <th>Owner</th>
                    <th>Node</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse(\$servers as \$server)
                    <tr>
                        <td>{{ \$server->id }}</td>
                        <td>{{ \$server->name }}</td>
                        <td>{{ \$server->user->username ?? 'Tidak diketahui' }}</td>
                        <td>{{ \$server->node->name ?? 'Tidak diketahui' }}</td>
                        <td>
                            @if(\$server->suspended)
                                <span class="badge badge-danger">Suspended</span>
                            @else
                                <span class="badge badge-success">Active</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="text-center text-muted">Tidak ada server ditemukan.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi tampilan Anti Lihat Server berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa melihat semua server."
