defmodule Wechat.Qrcode do
  use Wechat.Api
  # use @api to only import the methods defined in qrcode.exs
  # it contains the methods:
  # create_qrcode_ticket, get_qrcode
  @api [:qrcode]

  def create_ticket(scene, expire) when is_integer(scene) do
    create_qrcode_ticket(%{
      expire_seconds: expire,
      action_name: "QR_SCENE",
      action_info: %{scene: %{scene_id: scene}}
    })
  end

  def create_ticket(scene, expire) when is_binary(scene) do
    create_qrcode_ticket(%{
      expire_seconds: expire,
      action_name: "QR_STR_SCENE",
      action_info: %{scene: %{scene_str: scene}}
    })
  end

  def download(ticket, path) do
    # first urlencode
    encode_ticket = URI.encode_www_form(ticket)
    qrcode_data = get_qrcode(ticket: encode_ticket)
    File.write!(path, qrcode_data)
  end
end
