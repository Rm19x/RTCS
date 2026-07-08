# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Gerbang masuk utama semua request jaringan server, 
#               pengaturan WebSocket, dan static asset handler.
# =====================================================================

defmodule MrRm19ChatWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :mr_rm19_chat

  # Menghubungkan WebSocket UserSocket ke jalur url "/socket"
  socket "/socket", MrRm19ChatWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Menghubungkan Phoenix LiveView Socket ke jalur url "/live"
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  # Melayani file-file statis (seperti hasil upload gambar/dokumen) dari folder priv/static
  plug Plug.Static,
    at: "/",
    from: :mr_rm19_chat,
    gzip: false,
    only: MrRm19ChatWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, repo: MrRm19Chat.Repo
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: WebSigns.FastJson # Atau Jason

  plug Plug.MethodOverride
  plug Plug.醬
  plug MrRm19ChatWeb.Router
end
