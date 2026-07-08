# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Komponen Phoenix LiveView untuk mengontrol antarmuka 
#               utama chat dan pengaturan tema Dark Mode.
# =====================================================================

defmodule MrRm19ChatWeb.ChatLive do
  use MrRm19ChatWeb, :live_view

  alias MrRm19Chat.Accounts
  alias MrRm19Chat.Chat

  @impl true
  def mount(_params, session, socket) do
    # Mengambil data user berdasarkan session token
    user = Accounts.get_user!(session["user_id"])
    
    # Mendaftarkan proses LiveView ke PubSub agar menerima broadcast pesan baru secara real-time
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MrRm19Chat.PubSub, "room_shared_channel")
    end

    {:ok,
     assign(socket,
       current_user: user,
       active_room_id: nil,
       messages: [],
       dark_mode: false,
       text_input: ""
     )}
  end

  @impl true
  def handle_event("toggle_dark_mode", _params, socket) do
    # Mengubah keadaan tema aplikasi (Dark Mode / Light Mode)
    {:noreply, assign(socket, dark_mode: !socket.assigns.dark_mode)}
  end

  @impl true
  def handle_event("select_room", %{"room_id" => room_id}, socket) do
    room_id_int = String.to_integer(room_id)
    # Memuat riwayat chat dari database saat kamar dipilih
    # Di dunia nyata, ini memanggil fungsi list_messages dari konteks Chat
    query_messages = [] 

    {:noreply, assign(socket, active_room_id: room_id_int, messages: query_messages)}
  end

  @impl true
  def handle_event("send_message", %{"content" => content}, socket) do
    if String.trim(content) != "" do
      message_attrs = %{
        room_id: socket.assigns.active_room_id,
        user_id: socket.assigns.current_user.id,
        content: content
      }

      case Chat.send_message(message_attrs) do
        {:ok, message} ->
          # Menyiarkan pesan baru ke seluruh pelanggan PubSub
          Phoenix.PubSub.broadcast(MrRm19Chat.PubSub, "room_shared_channel", {:new_message, message})
          {:noreply, assign(socket, text_input: "")}

        _ ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    # Menerima broadcast real-time dan langsung memasukkannya ke dalam daftar chat di layar
    if message.room_id == socket.assigns.active_room_id do
      {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
    else
      {:noreply, socket}
    end
  end
end
