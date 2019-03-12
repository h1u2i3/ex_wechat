defmodule Wechat.Plugs.WechatMessageParserTest do
  use ExUnit.Case
  use Plug.Test

  defmodule MyRouter do
    use Plug.Router
    alias Wechat.Plugs.WechatMessageParserTest.WechatController

    plug(Wechat.Plugs.WechatSignatureResponder)
    plug(Wechat.Plugs.WechatMessageParser)
    plug(:match)
    plug(:dispatch)
    plug(:fetch_query_params)

    post "/wechat" do
      WechatController.create(conn, conn.params)
    end
  end

  defmodule WechatController do
    import Phoenix.Controller, only: [text: 2]
    use Wechat.Responder
  end

  @opts MyRouter.init([])

  test "should return forbidden when didn't post with verify params" do
    conn = conn(:post, "/wechat")

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "forbidden"
  end

  test "should return forbidden when post with wrong verify params" do
    conn = bad_verify_request()

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "forbidden"
  end

  test "should return success when post with right verify params" do
    conn = right_verify_request()

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "success"
  end

  test "should get right message when post with right verify params" do
    conn = right_verify_request()

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.assigns[:signature]
    assert conn.assigns[:message] == %{name: "Gan"}
    assert conn.resp_body == "success"
  end

  defp right_verify_request do
    %{
      conn(:post, "/wechat", "<xml><name>Gan</name></xml>")
      | params: %{
          "nonce" => "12345678",
          "timestamp" => "14273828218",
          "echostr" => "abcefghijkl",
          "signature" => "53ae624c4650281c69bf4055926c5ea9621ef1b2"
        }
    }
  end

  defp bad_verify_request do
    conn(:post, "/wechat",
      nonce: "12345678",
      timestamp: "14273828218",
      echostr: "abcefghijkl",
      signature: "wrongsingature"
    )
  end
end
