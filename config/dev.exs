# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Konfigurasi lingkungan lokal (development), pengaturan 
#               kredensial database lokal, dan modul debugging.
# =====================================================================

import Config

# Mengatur konfigurasi database PostgreSQL lokal
config :mr_rm19_chat, MrRm19Chat.Repo,
  username: "postgres",
  password: "postgres_password",
  hostname: "localhost",
  database: "mr_rm19_chat_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Mengatur port server web lokal ke port 4000
config :mr_rm19_chat, MrRm19ChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "Mr_Rm19_Handcrafted_Super_Secret_Key_For_Dev_Environment_4000"

# Mengaktifkan peninjauan perubahan file secara real-time (Live Reload)
config :mr_rm19_chat, MrRm19ChatWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/mr_rm19_chat_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Menonaktifkan kompilasi aset yang terlalu ketat saat development
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime