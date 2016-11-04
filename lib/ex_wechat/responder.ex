defmodule ExWechat.Responder do
  @module_doc """
    ExWechat.Responder is for make respond to wechat server.
    can be used with server verify and other things.
  """

  use ExWechat.Base # import token from ExWechat.Base
  import ExWechat.Utils.Crypto

  def wechat_verify_responder(%{"signature" => signature, "timestamp" => timestamp, 
          "nonce" => nonce, "echostr" => echostr) do
    case check_signature(signature, timestamp, nonce) do
      true -> echostr
      false -> "forbidden"
    end
  end

  defp check_signature(signature, timestamp, nonce) do
    [token, timestamp, nonce]
    |> Enum.sort
    |> Enum.join
    |> sha1_equal?(signature)
  end
end
