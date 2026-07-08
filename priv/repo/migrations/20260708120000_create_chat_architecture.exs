# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Skrip SQL migrasi untuk mendirikan arsitektur tabel 
#               users, rooms, members, dan messages di database.
# =====================================================================

defmodule MrRm19Chat.Repo.Migrations.CreateChatArchitecture do
  use Ecto.Migration

  def change do
    # 1. Membuat Tabel Pengguna (Users)
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :pin_lock_hash, :string
      add :blocked_users, {:array, :integer}, default: []

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])

    # 2. Membuat Tabel Kamar Chat (Rooms)
    create table(:rooms) do
      add :name, :string
      add :type, :string, null: false, default: "private"
      add :unique_link, :string

      timestamps()
    end

    create unique_index(:rooms, [:unique_link])

    # 3. Membuat Tabel Relasi Anggota (Members)
    create table(:members) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
      add :role, :string, null: false, default: "member"
      add :is_pinned, :boolean, null: false, default: false

      timestamps()
    end

    create index(:members, [:user_id])
    create index(:members, [:room_id])

    # 4. Membuat Tabel Riwayat Pesan (Messages)
    create table(:messages) do
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :content, :text
      add :media_url, :string
      add :media_type, :string
      add :reply_to_id, :integer
      add :is_deleted, :boolean, null: false, default: false

      timestamps()
    end

    create index(:messages, [:room_id])
    create index(:messages, [:user_id])
  end
end
