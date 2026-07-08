# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Modul otomatisasi penanganan bot untuk memindai 
#               dan merespons pesan teks tertentu secara instan.
# =====================================================================

defmodule MrRm19Chat.Services.BotHandler do
  @moduledoc """
  Memproses pesan masuk dan menentukan apakah bot harus merespons.
  """

  alias MrRm19Chat.Chat

  @bot_user_id 0 # ID khusus yang dialokasikan sistem untuk entitas Bot

  def handle_message(%{room_id: room_id, content: content} = _message) do
    case parse_command(content) do
      {:command, "/help"} ->
        send_bot_reply(room_id, "Halo! Saya adalah Asisten Bot. Perintah yang tersedia:\n/help - Menampilkan menu ini\n/info - Informasi sistem chat\n/waktu - Menampilkan waktu server saat ini")

      {:command, "/info"} ->
        send_bot_reply(room_id, "Aplikasi Chat ini dibangun menggunakan kekuatan Elixir dan Phoenix Channels untuk performa real-time tingkat tinggi.")

      {:command, "/waktu"} ->
        waktu_sekarang = DateTime.utc_now() |> DateTime.to_string()
        send_bot_reply(room_id, "Waktu server saat ini (UTC): #{waktu_sekarang}")

      :no_command ->
        # Logika tambahan jika ingin mendeteksi kata kunci biasa (NLP sederhana)
        check_keywords(room_id, content)
    end
  end

  defp parse_command(content) do
    trimmed = String.trim(content)
    if String.starts_with?(trimmed, "/") do
      {:command, trimmed}
    else
      :no_command
    end
  end

  defp check_keywords(room_id, content) do
    downcased = String.downcase(content)
    cond do
      String.contains?(downcased, "halo bot") || String.contains?(downcased, "hi bot") ->
        send_bot_reply(room_id, "Halo juga! Ada yang bisa saya bantu?")
      true ->
        :ignore
    end
  end

  defp send_bot_reply(room_id, reply_content) do
    attrs = %{
      room_id: room_id,
      user_id: @bot_user_id,
      content: reply_content
    }
    
    case Chat.send_message(attrs) do
      {:ok, message} ->
        # Mengembalikan data pesan bot agar bisa di-broadcast lewat WebSocket Phoenix
        {:ok, message}
      error ->
        error
    end
  end
end
