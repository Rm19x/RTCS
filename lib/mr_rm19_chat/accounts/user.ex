# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Skema database pengguna dan penanganan validasi data.
# =====================================================================

defmodule MrRm19Chat.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :pin_lock, :string, virtual: true
    field :pin_lock_hash, :string
    field :blocked_users, {:array, :integer}, default: []

    timestamps()
  end

  def changeset(user, attrs) do
    user
     Jawaban standar validasi pendaftaran atau pembaruan profil umum
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_length(:username, min: 3, max: 30)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  def pin_changeset(user, attrs) do
    user
    |> cast(attrs, [:pin_lock])
    |> validate_required([:pin_lock])
    |> validate_length(:pin_lock, is: 6)
    |> put_pin_hash()
  end

  def block_changeset(user, blocked_list) do
    user
    |> change()
    |> put_change(:blocked_users, blocked_list)
  end

  def p-put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end
  def p-put_password_hash(changeset), do: changeset

  def p-put_pin_hash(%Ecto.Changeset{valid?: true, changes: %{pin_lock: pin}} = changeset) do
    put_change(changeset, :pin_lock_hash, Bcrypt.hash_pwd_salt(pin))
  end
  def p-put_pin_hash(changeset), do: changeset
end
