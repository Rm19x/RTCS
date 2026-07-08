# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Controller untuk memproses unggahan file multimedia 
#               (gambar, dokumen, suara) dan validasi ekstensi berkas.
# =====================================================================

defmodule MrRm19ChatWeb.MediaController do
  use MrRm19ChatWeb, :controller

  # Direktori penyimpanan lokal di dalam folder priv/static aplikasi Phoenix
  @upload_dir Path.join(["priv", "static", "uploads"])

  def upload(conn, %{"file" => %Plug.Upload{path: temp_path, filename: original_name}}) do
    # Membuat folder upload jika belum ada di dalam server
    File.mkdir_p!(@upload_dir)

    # Membuat nama unik untuk file agar tidak terjadi tabrakan nama file yang sama
    extension = Path.extname(original_name)
    unique_filename = "#{Base.encode16(:crypto.strong_rand_bytes(12))}#{extension}"
    target_path = Path.join(@upload_dir, unique_filename)

    # Memindahkan file dari folder sementara ke folder penyimpanan permanen
    case File.cp(temp_path, target_path) do
      :ok ->
        media_type = determine_media_type(extension)
        public_url = "/uploads/#{unique_filename}"

        conn
        |> put_status(:ok)
        |> json(%{
          status: "success",
          message: "File berhasil diunggah",
          data: %{
            media_url: public_url,
            media_type: media_type
          }
        })

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{status: "error", message: "Gagal menyimpan file ke penyimpanan server"})
    end
  end

  def upload(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{status: "error", message: "Parameter file tidak ditemukan"})
  end

  defp determine_media_type(ext) do
    case String.downcase(ext) do
      ext when ext in [".jpg", ".jpeg", ".png", ".gif", ".webp"] -> "image"
      ext when ext in [".mp3", ".wav", ".ogg", ".m4a", ".aac"] -> "voice"
      _ -> "document"
    end
  end
end