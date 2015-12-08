class Bootstrap

  def self.start
    generate_groups
    update_default_group_permissions
  end

  def self.generate_groups
    generate_superuser_group
    generate_pigeon_group
  end

  def self.generate_superuser_group
    return unless ServerGroup.find_by_name("Superuser").empty?
    id = ServerGroup.create("Superuser")
    ServerGroup.edit_group_permission(id, "b_virtualserver_info_view", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_connectioninfo_view", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_channel_list", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_client_list", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_token_use", 1)

    ServerGroup.edit_group_permission(id, "b_channel_info_view", 1)
    ServerGroup.edit_group_permission(id, "b_channel_create_temporary", 1)
    ServerGroup.edit_group_permission(id, "b_channel_create_modify_with_codec_speex8", 1)
    ServerGroup.edit_group_permission(id, "b_channel_create_modify_with_codec_speex16", 1)
    ServerGroup.edit_group_permission(id, "i_channel_create_modify_with_codec_maxquality", 7)
    ServerGroup.edit_group_permission(id, "i_channel_create_modify_with_codec_latency_factor_min", 1)
    ServerGroup.edit_group_permission(id, "i_channel_modify_power", 50)
    ServerGroup.edit_group_permission(id, "b_channel_join_permanent", 1)
    ServerGroup.edit_group_permission(id, "b_channel_join_semi_permanent", 1)
    ServerGroup.edit_group_permission(id, "b_channel_join_temporary", 1)
    ServerGroup.edit_group_permission(id, "i_channel_join_power", 50)
    ServerGroup.edit_group_permission(id, "i_channel_subscribe_power", 50)
    ServerGroup.edit_group_permission(id, "i_channel_description_view_power", 50)
    ServerGroup.edit_group_permission(id, "i_channel_max_depth", 5)

    ServerGroup.edit_group_permission(id, "b_virtualserver_servergroup_list", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_servergroup_client_list", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_channelgroup_list", 1)
    ServerGroup.edit_group_permission(id, "b_virtualserver_channelgroup_client_list", 1)

    ServerGroup.edit_group_permission(id, "i_group_modify_power", 72)
    ServerGroup.edit_group_permission(id, "i_group_needed_modify_power", 72, true)
    ServerGroup.edit_group_permission(id, "i_group_member_add_power", 72)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_add_power", 72, true)
    ServerGroup.edit_group_permission(id, "i_group_member_remove_power", 73)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_remove_power", 73, true)
    ServerGroup.edit_group_permission(id, "i_permission_modify_power", 72)

    ServerGroup.edit_group_permission(id, "b_group_is_permanent", 1)
    ServerGroup.edit_group_permission(id, "i_group_auto_update_type", 30)
    ServerGroup.edit_group_permission(id, "i_group_sort_id", 5)

    ServerGroup.edit_group_permission(id, "b_client_info_view", 1)
    ServerGroup.edit_group_permission(id, "b_client_permissionoverview_view", 1)
    ServerGroup.edit_group_permission(id, "b_client_permissionoverview_own", 1)
    ServerGroup.edit_group_permission(id, "i_client_needed_serverquery_view_power", 75)

    ServerGroup.edit_group_permission(id, "i_client_needed_kick_from_server_power", 50)
    ServerGroup.edit_group_permission(id, "i_client_needed_kick_from_channel_power", 50)
    ServerGroup.edit_group_permission(id, "i_client_needed_ban_power", 50)
    ServerGroup.edit_group_permission(id, "i_client_needed_move_power", 50)
    ServerGroup.edit_group_permission(id, "i_client_complain_power", 50)
    ServerGroup.edit_group_permission(id, "i_client_needed_complain_power", 50)

    ServerGroup.edit_group_permission(id, "i_client_private_textmessage_power", 50)
    ServerGroup.edit_group_permission(id, "b_client_server_textmessage_send", 1)
    ServerGroup.edit_group_permission(id, "b_client_channel_textmessage_send", 1)
    ServerGroup.edit_group_permission(id, "b_client_offline_textmessage_send", 1)
    ServerGroup.edit_group_permission(id, "i_client_poke_power", 50)

    ServerGroup.edit_group_permission(id, "i_client_permission_modify_power", 72)
    ServerGroup.edit_group_permission(id, "i_client_needed_permission_modify_power", 72)
    ServerGroup.edit_group_permission(id, "i_client_max_clones_uid", 2)
    ServerGroup.edit_group_permission(id, "i_client_max_avatar_filesize", 200000)
    ServerGroup.edit_group_permission(id, "i_client_max_channel_subscriptions", -1)
    ServerGroup.edit_group_permission(id, "b_client_request_talker", 1)
  end

  def self.generate_pigeon_group
    return unless ServerGroup.find_by_name("Pigeonator").empty?
    id = ServerGroup.create("Pigeonator")
    ServerGroup.edit_group_permission(id, "i_group_modify_power", 72)
    ServerGroup.edit_group_permission(id, "i_group_needed_modify_power", 72, true)
    ServerGroup.edit_group_permission(id, "i_group_member_add_power", 72)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_add_power", 72, true)
    ServerGroup.edit_group_permission(id, "i_group_member_remove_power", 72)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_remove_power", 72, true)
    ServerGroup.edit_group_permission(id, "i_permission_modify_power", 72)
    ServerGroup.edit_group_permission(id, "b_group_is_permanent", 1)
    ServerGroup.edit_group_permission(id, "i_group_sort_id", 52)
    ServerGroup.edit_group_permission(id, "i_client_permission_modify_power", 15)
    ServerGroup.edit_group_permission(id, "i_client_needed_permission_modify_power", 5)
  end

  def self.update_default_group_permissions
    modify_permissions_server_admin_group
    modify_permissions_normal_group
    modify_permissions_server_guest_group
  end

  def self.modify_permissions_normal_group
    id = ServerGroup.normal.first.id
    ServerGroup.edit_group_permission(id, "i_group_modify_power", 70)
    ServerGroup.edit_group_permission(id, "i_group_needed_modify_power", 70)
    ServerGroup.edit_group_permission(id, "i_group_member_add_power", 70)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_add_power", 70)
    ServerGroup.edit_group_permission(id, "i_group_member_remove_power", 70)
    ServerGroup.edit_group_permission(id, "i_group_needed_member_remove_power", 70)
    ServerGroup.edit_group_permission(id, "i_permission_modify_power", 70)
    ServerGroup.edit_group_permission(id, "b_group_is_permanent", 1)
    ServerGroup.edit_group_permission(id, "i_group_sort_id", 10)
    ServerGroup.edit_group_permission(id, "i_client_permission_modify_power", 71)
    ServerGroup.edit_group_permission(id, "i_client_needed_permission_modify_power", 70)
  end

  def self.modify_permissions_server_admin_group
    id = ServerGroup.server_admin.first.id
    ServerGroup.edit_group_permission(id, "i_group_sort_id", 1)
  end

  def self.modify_permissions_server_guest_group
    id = ServerGroup.guest.first.id
    ServerGroup.edit_group_permission(id, "i_group_sort_id", 200)
  end

end
