# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Modul manajemen akun untuk registrasi, login, 
#               pemblokiran kontak, dan kunci aplikasi.
# =====================================================================

defmodule MrRm19Chat.Accounts do
  import Ecto.Query, warn: false
  alias MrRm19Chat.Repo
  alias MrRm19Chat.Accounts.User

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        Bcrypt.no_user_verify()
        {:error, :not_found}
    end
  end

  def set_app_pin(user_id, pin_attrs) do
    user = Repo.get!(User, user_id)

    user
    |> User.pin_changeset(pin_attrs)
    |> Repo.update()
  end

  def verify_app_pin(user_id, pin) do
    user = Repo.get!(User, user_id)

    cond do
      user.pin_lock_hash && Bcrypt.verify_pass(pin, user.pin_lock_hash) ->
        {:ok, :verified}
      true ->
        {:error, :invalid_pin}
    end
  end

  def block_user(user_id, target_user_id) do
    user = Repo.get!(User, user_id)
    
    if target_user_id not in user.blocked_users do
      updated_list = user.blocked_users ++ [target_user_id]
      user
      |> User.block_changeset(updated_list)
      |> Repo.update()
    else
      {:ok, user}
    end
  end

  def unblock_user(user_id, target_user_id) do
    user = Repo.get!(User, user_id)

    if target_user_id in user.blocked_users do
      updated_list = List.delete(user.blocked_users, target_user_id)
      user
      |> User.block_changeset(updated_list)
      |> Repo.update()
    else
      {:ok, user}
    end
  end

  def is_blocked?(user_id, target_user_id) do
    user = Repo.get!(User, user_id)
    target_user_id in user.blocked_users
  end

  def get_user!(id), do: Repo.get!(User, id)
end
