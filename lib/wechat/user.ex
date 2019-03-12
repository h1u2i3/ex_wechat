defmodule Wechat.User do
  @moduledoc """
  Module to operate with user.
  """
  alias Wechat.User.Info
  alias Wechat.User.Group

  @doc """
  Get user info from server.
  """
  def info(module \\ Wechat, openid)

  def info(module, openid) when is_binary(openid) do
    [openid: openid]
    |> module.get_user_info
    |> gen_info_struct
  end

  def info(module, openid) when is_list(openid) do
    openid
    |> gen_info_openids_list
    |> module.get_users_info
    |> Map.get(:user_info_list)
    |> Enum.map(&gen_info_struct/1)
  end

  @doc """
  Get all the group.
  """
  def groups(module \\ Wechat) do
    module.get_groups
    |> Map.get(:groups)
    |> Enum.map(&gen_group_struct/1)
  end

  @doc """
  Add user to the group
  """
  def group_user_add(module \\ Wechat, openid, group)

  def group_user_add(module, openid, group) when is_binary(openid) do
    %{openid: openid, to_groupid: group.id}
    |> module.update_group_member
  end

  def group_user_add(module, openid, group) when is_list(openid) do
    openid
    |> gen_group_openids_list
    |> Map.put(:to_groupid, group.id)
    |> module.batch_update_group_member
  end

  @doc """
  Get user list from server.
  """
  def list(module \\ Wechat) do
    module.get_user_list
  end

  defp gen_info_openids_list(openids) do
    %{
      user_list:
        Enum.map(openids, fn openid ->
          %{openid: openid, lang: "zh-CN"}
        end)
    }
  end

  defp gen_group_openids_list(openids) do
    %{openid_list: openids}
  end

  defp gen_info_struct(info) do
    struct(Info, info)
  end

  defp gen_group_struct(group) do
    struct(Group, group)
  end

  defmodule Info do
    @moduledoc false
    defstruct city: nil,
              country: nil,
              groupid: nil,
              headimgurl: nil,
              language: nil,
              nickname: nil,
              openid: nil,
              province: nil,
              remark: nil,
              sex: nil,
              subscribe: nil,
              subscribe_time: nil,
              tagid_list: nil
  end

  defmodule Group do
    @moduledoc false
    defstruct count: nil, id: nil, name: nil
  end
end
