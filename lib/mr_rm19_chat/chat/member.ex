# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Skema relasi anggota di dalam kamar obrolan atau grup.
# =====================================================================

defmodule MrRm19Chat.Chat.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :role, :string, default: "member" # "admin", "member"
    field :is_pinned, :boolean, default: false
    
    belongs_to :room, MrRm19Chat.Chat.Room
    belongs_to :user, MrRm19Chat.Accounts.User

    timestamps()
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:room_id, :user_id, :role, :is_pinned])
    |> validate_required([:room_id, :user_id])
    |> validate_inclusion(:role, ["admin", "member"])
  end
end