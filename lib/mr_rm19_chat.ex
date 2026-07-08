# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Modul entri aplikasi utama yang mengatur siklus hidup 
#               dan supervision tree dari seluruh layanan backend.
# =====================================================================

defmodule MrRm19Chat do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Memulai koneksi database PostgreSQL
      MrRm19Chat.Repo,
      # Memulai sistem telemetri
      MrRm19ChatWeb.Telemetry,
      # Memulai sistem PubSub untuk komunikasi internal real-time
      {Phoenix.PubSub, name: MrRm19Chat.PubSub},
      # Memulai pelacakan kehadiran status online/offline
      MrRm19ChatWeb.Presence,
      # Memulai server web gerbang utama (Endpoint)
      MrRm19ChatWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MrRm19Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    MrRm19ChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
