# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Pusat kendali WebSocket untuk penyiaran pesan, penanganan 
#               status mengetik, indikator online, dan integrasi bot/penerjemah.
# =====================================================================

defmodule MrRm19ChatWeb.RoomChannel do
  use MrRm19ChatWeb, :channel
  alias MrRm19ChatWeb.Presence
  alias MrRm19Chat.Chat
  alias MrRm19Chat.Services.{BotHandler, Translator}

  @impl true
  def join("room:" <> room_id, _payload, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :room_id, String.to_integer(room_id))}
  end

  @impl true
  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id
    room_id = socket.assigns.room_id

    # Mencatat pengguna ke sistem Presence (Status Online)
    {:ok, _} = Presence.track(socket, to_string(user_id), %{
      online_at: inspect(System.system_time(:second))
    })

    # Kirim daftar status online terbaru ke pengguna yang baru gabung
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_message", payload, socket) do
    user_id = socket.assigns.user_id
    room_id = socket.assigns.room_id

    message_attrs = %{
      "room_id" => room_id,
      "user_id" => user_id,
      "content" => payload["content"],
      "media_url" => payload["media_url"],
      "media_type" => payload["media_type"],
      "reply_to_id" => payload["reply_to_id"]
    }

    case Chat.send_message(message_attrs) do
      {:ok, message} ->
        # Broadcast pesan asli ke seluruh anggota kamar chat
        broadcast!(socket, "shout_message", message)

        # Otomatisasi 1: Periksa apakah bot perlu merespons pesan ini
        Task.start(fn -> 
          case BotHandler.handle_message(message) do
            {:ok, bot_message} -> broadcast!(socket, "shout_message", bot_message)
            _ -> :ok
          end
        end)

        # Otomatisasi 2: Deteksi jika pengguna meminta terjemahan instan (payload opsional)
        if payload["translate_to"] do
          Task.start(fn ->
            case Translator.translate_text(message.content, payload["translate_to"]) do
              {:ok, translated_text} ->
                push(socket, "translated_message", %{message_id: message.id, text: translated_text})
              _ -> :ok
            end
          end)
        end

        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Gagal menyimpan pesan"}}, socket}
    end
  end

  @impl true
  def handle_in("typing", %{"is_typing" => is_typing}, socket) do
    user_id = socket.assigns.user_id
    
    # Broadcast status mengetik ke anggota kamar lain agar muncul "X sedang mengetik..."
    broadcast_from!(socket, "user_typing", %{
      user_id: user_id,
      is_typing: is_typing
    })

    {:noreply, socket}
  end

  @impl true
  def handle_in("message_status", %{"message_id" => msg_id, "status" => status}, socket) do
    # Menangani status pengiriman: "delivered" (centang dua) atau "read" (centang biru)
    broadcast!(socket, "update_status", %{
      message_id: msg_id,
      status: status,
      user_id: socket.assigns.user_id
    })
    
    {:noreply, socket}
  end
end