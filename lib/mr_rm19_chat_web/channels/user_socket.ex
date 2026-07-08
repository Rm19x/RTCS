# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Mengatur autentikasi awal dan manajemen koneksi 
#               WebSocket masuk untuk setiap pengguna.
# =====================================================================

defmodule MrRm19ChatWeb.UserSocket do
  use Phoenix.Socket

  # Menghubungkan jalur channel ke modul RoomChannel
  channel "room:*", MrRm19ChatWeb.RoomChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    # Memverifikasi token JWT pengguna (misalnya berumur 2 minggu)
    case Phoenix.Token.verify(socket, "user socket salt", token, max_age: 1_209_600) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  @impl true
  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end