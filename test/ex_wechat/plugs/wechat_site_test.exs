defmodule ExWechat.Plugs.WechatSiteTest do
  use ExUnit.Case
  use Plug.Test

  alias ExWechat.Tools.WechatCase

  defmodule MyRouter do
    use Plug.Router
    alias ExWechat.Plugs.WechatSiteTest.WechatSiteController

    plug :match
    plug :dispatch
    plug ExWechat.Plugs.WechatWebsite, url: "http://wechat.one-picture.com",
      state: WechatSiteController

    get "/wechat" do
      WechatSiteController.index(conn, conn.params)
    end
  end

  defmodule OtherRouter do
    use Plug.Router
    alias ExWechat.Plugs.WechatSiteTest.OtherController

    plug :match
    plug :dispatch
    plug ExWechat.Plugs.WechatWebsite, url: "http://wechat.one-picture.com"

    get "/other" do
      OtherController.index(conn, conn.params)
    end
  end

  defmodule OtherController do
    def index(conn, _params) do
      conn
    end
  end

  defmodule WechatSiteController do
    def index(conn, _params) do
      conn
    end

    def state do
      "other"
    end
  end

  @opts MyRouter.init([])
  @other OtherRouter.init([])

  test "should get redirect when visit the wechat website" do
    conn = conn(:get, "/wechat")

    conn = MyRouter.call(conn, @opts)
    [_, {_, url}] = conn.resp_headers
    uri = URI.parse(url)

    assert conn.state == :sent
    assert conn.status == 302
    assert uri.host == "open.weixin.qq.com"
    assert uri.query == "appid=yourappid&redirect_uri=http%3A%2F%2Fwechat" <>
      ".one-picture.com&response_type=code&scope=snsapi_base&state=other"
  end

  test "should get redirect with default state when visit the wechat website" do
    conn = conn(:get, "/other")

    conn = OtherRouter.call(conn, @other)
    [_, {_, url}] = conn.resp_headers
    uri = URI.parse(url)

    assert conn.state == :sent
    assert conn.status == 302
    assert uri.host == "open.weixin.qq.com"
    assert uri.query == "appid=yourappid&redirect_uri=http%3A%2F%2Fwechat" <>
      ".one-picture.com&response_type=code&scope=snsapi_base&state=ex_wechat_state"
  end

  test "visit with code and state should get the info of user" do
    WechatCase.wechat_site_fake(%{openid: "openid"})
    conn =
      :get
      |> conn("/wechat", [code: "code", state: "other"])
      |> init_test_session(%{})

    conn = MyRouter.call(conn, @opts)

    assert conn.assigns[:wechat_result] == %{openid: "openid"}
  end
end
