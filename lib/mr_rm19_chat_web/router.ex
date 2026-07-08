# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Manajemen routing url untuk memisahkan jalur internal 
#               API tradisional dan interaksi LiveView.
# =====================================================================

defmodule MrRm19ChatWeb.Router do
  use MrRm19ChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MrRm19ChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Jalur khusus aplikasi web utama (LiveView)
  scope "/", MrRm19ChatWeb do
    pipe_through :browser

    live "/chat", ChatLive, :index
  end

  # Jalur khusus REST API (Auth & Media Upload)
  scope "/api", MrRm19ChatWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/upload", MediaController, :upload
  end
end
