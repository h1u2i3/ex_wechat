defmodule ExWechat.Message do
  @moduledoc """
  Wechat Message.
  """

  alias ExWechat.Message.XmlMessage
  alias ExWechat.Message.JsonMessage

  @doc """
  Send custom message to a special openid.
  If user don't react with your wechat in 24 hours, you cann't send this
  kind of message to user.
  message_params:

      %{ voice: %{media_id: "id"} }
      %{ text: %{content: "content"} }
      %{ image: %{media_id: "id"} }
  """
  @spec send_custom(Module.t, String.t, Map.t) :: Map.t | Tuple.t
  def send_custom(module \\ ExWechat, openid,  message_params) do
    message_params
    |> JsonMessage.build_custom(openid)
    |> module.send_custom_message
  end

  @doc """
  Passive Message, react to user.
  Just need to generate the xml message, don't need to send to wechat server.
  """
  def generate_passive(origin_message \\ nil, message_params)
  def generate_passive(nil, message_params) do
    message_params
    |> XmlMessage.build
  end
  def generate_passive(origin_message, message_params) do
    message_params
    |> Enum.to_list
    |> Keyword.put(:tousername, origin_message.fromusername)
    |> Keyword.put(:fromusername, origin_message.tousername)
    |> XmlMessage.build
  end

  @doc """
  Template Message, should send to wechat server.
  """
  def send_template(module \\ ExWechat, openid, message_params) do
    message_params
    |> JsonMessage.build_template(openid)
    |> module.send_template_message
  end

  @doc """
  Mass Message.
  Mass message should send to wechat server.
  """
  def send_mass(module \\ ExWechat, target, message_params) do
    message_params
    |> JsonMessage.build_mass(target)
    |> module.send_mass_message
  end
end
