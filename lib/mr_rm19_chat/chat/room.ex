# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Skema database untuk entitas Kamar Chat (Kamar, Grup, & Siaran)
# =====================================================================

defmodule MrRm19Chat.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :type, :unique_link]}
  schema "rooms" do
    field :name, :string
    field :type, :string, default: "private" # "private", "group", "broadcast"
    field :unique_link, :string
    
    has_many :members, MrRm19Chat.Chat.Member
    has_many :messages, MrRm19Chat.Chat.Message

    timestamps()
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :type, :unique_link])
    |> validate_required([:type])
    |> validate_inclusion(:type, ["private", "group", "broadcast"])
    |> unique_constraint(:unique_link)
    |> generate_unique_link()
  end

  defp generate_unique_link(%Ecto.Changeset{valid?: true, changes: %{type: "group"}} = changeset) do
    case get_field(changeset, :unique_link) do
      nil -> put_change(changeset, :unique_link, Base.encode16(:crypto.strong_rand_bytes(8)))
      _ -> changeset
    end
  end
  defp generate_unique_link(changeset), do: changeset
end