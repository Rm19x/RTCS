# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Modul layanan terintegrasi untuk penerjemahan teks 
#               pesan secara otomatis via HTTP API.
# =====================================================================

defmodule MrRm19Chat.Services.Translator do
  @moduledoc """
  Menangani komunikasi dengan API penerjemah eksternal.
  """

  # Pustaka HTTPoison atau Req biasanya digunakan di sini
  # Untuk contoh ini kita gunakan skema request standar Elixir / HTTPoison

  @api_url "https://api.libretranslate.com/translate"

  def translate_text(text, target_lang) do
    body = Jason.encode!(%{
      q: text,
      source: "auto",
      target: target_lang,
      format: "text"
    })

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(@api_url, body, headers, [timeout: 5000, recv_timeout: 5000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: res_body}} ->
        case Jason.decode(res_body) do
          {:ok, %{"translatedText" => translated}} -> {:ok, translated}
          _ -> {:error, :parse_failed}
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, {:api_error, status}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end