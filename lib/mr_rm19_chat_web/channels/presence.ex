# =====================================================================
# Author      : Mr.Rm19
# GitHub      : https://github.com/Rm19x
# Description : Menyediakan infrastruktur pelacakan kehadiran pengguna 
#               (online/offline) secara real-time di server.
# =====================================================================

defmodule MrRm19ChatWeb.Presence do
  use Phoenix.Presence,
    otp_app: :mr_rm19_chat,
    pubsub_server: MrRm19Chat.PubSub
end
