# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Controller untuk menangani registrasi akun dan proses 
#               autentikasi login guna mendapatkan token enkripsi.
# =====================================================================

defmodule MrRm19ChatWeb.AuthController do
  use MrRm19ChatWeb, :controller

  alias MrRm19Chat.Accounts

  def register(conn, %{"username" => username, "email" => email, "password" => password}) do
    user_params = %{"username" => username, "email" => email, "password" => password}

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{status: "success", message: "User berhasil didaftarkan", data: user})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # Membuat token aman dengan Phoenix.Token untuk digunakan pada koneksi WebSocket
        token = Phoenix.Token.sign(MrRm19ChatWeb.Endpoint, "user socket salt", user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          status: "success",
          message: "Login berhasil",
          data: %{
            token: token,
            user: user
          }
        })

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{status: "error", message: "Password yang Anda masukkan salah"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Email tidak terdaftar dalam sistem"})
    end
  end

  defp translate_error({msg, opts}) do
    # Fungsi pembantu untuk menerjemahkan error Ecto ke format teks mentah
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
