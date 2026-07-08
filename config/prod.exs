# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Konfigurasi statis lingkungan produksi, optimalisasi 
#               aset, dan manajemen logger tingkat tinggi.
# =====================================================================

import Config

# Mengaktifkan manifest file statis untuk pembacaan aset yang di-cache
config :mr_rm19_chat, MrRm19ChatWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Membatasi pencatatan logger hanya untuk tingkat :info dan :error di server produksi
config :logger, :console, level: :info