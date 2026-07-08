# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Skema database rekaman isi pesan teks, media, dan suara.
# =====================================================================

defmodule MrRm19Chat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :room_id, :user_id, :content, :media_url, :media_type, :reply_to_id, :is_deleted]}
  schema "messages" do
    field :content, :string
    field :media_url, :string
    field :media_type, :string # "image", "document", "voice", nil
    field :reply_to_id, :integer
    field :is_deleted, :boolean, default: false

    belongs_to :room, MrRm19Chat.Chat.Room
    belongs_to :user, MrRm19Chat.Accounts.User

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :media_url, :media_type, :reply_to_id, :room_id, :user_id, :is_deleted])
    |> validate_required([:room_id, :user_id])
    |> validate_media_type()
  end

  defp validate_media_type(changeset) do
    media_url = get_field(changeset, :media_url)
    media_type = get_field(changeset, :media_type)

    if media_url && is_nil(media_type) do
      add_error(changeset, :media_type, "harus ditentukan jika media_url ada")
    else
      changeset
    end
  end
end