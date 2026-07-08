# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Modul interaksi utama penanganan pesan, manipulasi grup, 
#               pencarian riwayat chat, dan sistem tautan undangan.
# =====================================================================

defmodule MrRm19Chat.Chat do
  import Ecto.Query, warn: false
  alias MrRm19Chat.Repo
  alias MrRm19Chat.Chat.{Room, Member, Message}

  def create_private_room(user_id, target_user_id) do
    # Memeriksa apakah room privat antar kedua user sudah ada
    query = from r in Room,
              join: m1 in Member, on: m1.room_id == r.id,
              join: m2 in Member, on: m2.room_id == r.id,
              where: r.type == "private" and m1.user_id == ^user_id and m2.user_id == ^target_user_id,
              select: r

    case Repo.one(query) do
      nil ->
        Repo.transaction(fn ->
          {:ok, room} = %Room{type: "private"} |> Room.changeset(%{}) |> Repo.insert()
          %Member{} |> Member.changeset(%{room_id: room.id, user_id: user_id}) |> Repo.insert!()
          %Member{} |> Member.changeset(%{room_id: room.id, user_id: target_user_id}) |> Repo.insert!()
          room
        end)
      room -> {:ok, room}
    end
  end

  def create_group_room(creator_id, name) do
    Repo.transaction(fn ->
      {:ok, room} = %Room{type: "group", name: name} |> Room.changeset(%{}) |> Repo.insert()
      %Member{} |> Member.changeset(%{room_id: room.id, user_id: creator_id, role: "admin"}) |> Repo.insert!()
      room
    end)
  end

  def add_group_member(room_id, admin_id, new_member_id) do
    if is_admin?(room_id, admin_id) do
      %Member{}
      |> Member.changeset(%{room_id: room_id, user_id: new_member_id, role: "member"})
      |> Repo.insert()
    else
      {:error, :unauthorized}
    end
  end

  def join_room_by_link(user_id, unique_link) do
    case Repo.get_by(Room, unique_link: unique_link) do
      nil -> {:error, :not_found}
      room ->
        %Member{}
        |> Member.changeset(%{room_id: room.id, user_id: user_id, role: "member"})
        |> Repo.insert()
    end
  end

  def pin_room(user_id, room_id) do
    member = Repo.get_by!(Member, user_id: user_id, room_id: room_id)
    member |> Ecto.Changeset.change(is_pinned: true) |> Repo.update()
  end

  def send_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def edit_message(message_id, user_id, new_content) do
    message = Repo.get!(Message, message_id)
    if message.user_id == user_id and not message.is_deleted do
      message |> Ecto.Changeset.change(content: new_content) |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  def delete_for_everyone(message_id, user_id) do
    message = Repo.get!(Message, message_id)
    if message.user_id == user_id do
      message 
      |> Ecto.Changeset.change(is_deleted: true, content: "Pesan ini telah dihapus", media_url: nil, media_type: nil) 
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  def search_messages(room_id, query_string) do
    search_query = "%#{query_string}%"
    query = from m in Message,
              where: m.room_id == ^room_id and ilike(m.content, ^search_query) and m.is_deleted == false,
              order_by: [desc: m.inserted_at]
    Repo.all(query)
  end

  def is_admin?(room_id, user_id) do
    case Repo.get_by(Member, room_id: room_id, user_id: user_id) do
      nil -> false
      member -> member.role == "admin"
    end
  end
end
