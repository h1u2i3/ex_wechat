defmodule ExWechat.Message.JsonMessage do
  @moduledoc """
  Module to deal with json message.
  """

  @doc """
  Build custom message.
  """
  def build_custom(message_params, target)
  def build_custom(message_params, target) when is_list(message_params) do
    build_custom(message_params |> Enum.into(%{}), target)
  end
  def build_custom(message_params, target) when is_map(message_params) do
    message_params
    |> Map.put(:msgtype, message_params |> get_msgtype)
    |> Map.put(:touser, target)
  end

  @doc """
  Build Template message.
  """
  def build_template(message_params, target)
  def build_template(message_params, target) when is_list(message_params) do
    build_template(message_params |> Enum.into(%{}), target)
  end
  def build_template(message_params, target) do
    message_params
    |> Map.put(:touser, target)
  end

  @doc """
  Build Mass message.
  """
  def build_mass(message_params, target)
  def build_mass(_message_params, target) when is_binary(target) do
    raise "at least two openid!"
  end
  def build_mass(message_params, target) when is_list(message_params) do
    if length(target) == 1, do: raise "at least two openid!"
    build_mass(message_params |> Enum.into(%{}), target)
  end
  def build_mass(message_params, target) do
    message_params
    |> Map.put(:msgtype, message_params |> get_msgtype)
    |> Map.put(:touser, target)
  end

  defp get_msgtype(message_params) do
    message_params
    |> Map.keys
    |> List.first
    |> Atom.to_string
  end
end
