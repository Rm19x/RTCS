# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Konfigurasi dinamis runtime untuk memuat environment 
#               variables (DB URL, Secret Key, Port) secara aman di prod.
# =====================================================================

import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      Environment variable SECRET_KEY_BASE tidak ditemukan.
      Silakan buat kode rahasia dengan perintah: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :mr_rm19_chat, MrRm19ChatWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      Environment variable DATABASE_URL tidak ditemukan.
      Format contoh: ecto://USER:PASS@HOST/DATABASE
      """

  config :mr_rm19_chat, MrRm19Chat.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
end