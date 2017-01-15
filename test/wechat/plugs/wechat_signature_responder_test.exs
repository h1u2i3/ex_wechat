defmodule Wechat.Plugs.WechatSignatureResponderTest do
  use ExUnit.Case
  use Plug.Test

  defmodule MyRouter do
    use Plug.Router
    alias Wechat.Plugs.WechatSignatureResponderTest.WechatController

    plug Wechat.Plugs.WechatSignatureResponder
    plug Wechat.Plugs.WechatMessageParser
    plug :match
    plug :dispatch

    get "/wechat" do
      WechatController.index(conn, fetch_query_params(conn))
    end
  end

  defmodule WechatController do
    import Phoenix.Controller, only: [text: 2]
    use Wechat.Responder
  end

  @opts MyRouter.init([])

  test "should get forbidden when visit with no params" do
    conn = bad_verify_request()

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "forbidden"
  end

  test "should get forbidden when visit with bad verify params" do
    conn = conn(:get, "/wechat")

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "forbidden"
  end

  test "should get the params noncestr with right params" do
    conn = right_verify_request()

    conn = MyRouter.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "abcefghijkl"
  end

  test "should not generate the message assgins" do
    conn = right_verify_request()

    conn = MyRouter.call(conn, @opts)

    refute conn.assigns[:message]
  end

  defp right_verify_request do
    conn(:get, "/wechat",
      %{"nonce" => "12345678", "timestamp" => "14273828218",
        "echostr" => "abcefghijkl",
        "signature" => "53ae624c4650281c69bf4055926c5ea9621ef1b2"})
  end

  defp bad_verify_request do
    conn(:get, "/wechat",
      %{"nonce" => "12345678", "timestamp" => "14273828218",
        "echostr" => "abcefghijkl",
        "signature" => "wrongsingature"})
  end
end
