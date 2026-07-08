# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Basis konfigurasi global aplikasi untuk endpoint web, 
#               manajemen database Ecto, dan format parser JSON.
# =====================================================================

import Config

config :mr_rm19_chat,
  ecto_repos: [MrRm19Chat.Repo]

# Konfigurasi Endpoint Server Phoenix
config :mr_rm19_chat, MrRm19ChatWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: MrRm19ChatWeb.ErrorHTML, json: MrRm19ChatWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MrRm19Chat.PubSub,
  live_view: [signing_salt: "Mr_Rm19_Secure_LiveView_Salt_2026"]

# Mengonfigurasi pustaka enkripsi Bcrypt
config :bcrypt_elixir, log_rounds: 12

# Konfigurasi sistem pencatatan log (Logger)
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Menggunakan Jason untuk parsing JSON di Phoenix
config :phoenix, :json_library, Jason

# Memuat konfigurasi spesifik lingkungan kerja (dev.exs, prod.exs, dll)
import_config "#{config_env()}.exs"
