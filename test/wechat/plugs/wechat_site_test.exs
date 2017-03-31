defmodule Wechat.Plugs.WechatSiteTest do
  use ExUnit.Case
  use Plug.Test

  alias Wechat.TestCase

  defmodule MyRouter do
    use Plug.Router
    alias Wechat.Plugs.WechatSiteTest.WechatSiteController

    plug :match
    plug :dispatch
    plug :fetch_query_params
    plug :init_test_session
    plug Wechat.Plugs.WechatWebsite, host: "http://wechat.one-picture.com",
      state: WechatSiteController

    get "/wechat" do
      WechatSiteController.index(conn, conn.params)
    end
  end

  defmodule OtherRouter do
    use Plug.Router
    alias Wechat.Plugs.WechatSiteTest.OtherController

    plug :match
    plug :dispatch
    plug :fetch_query_params
    plug :init_test_session
    plug Wechat.Plugs.WechatWebsite, host: "http://wechat.one-picture.com"

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
      ".one-picture.com%2Fwechat&response_type=code&scope=snsapi_base&state=other"
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
      ".one-picture.com%2Fother&response_type=code&scope=snsapi_base&state=ex_wechat_state"
  end

  test "visit with code and state should get the info of user" do
    TestCase.wechat_site_fake(%{openid: "openid"})
    conn = conn(:get, "/wechat", [code: "code", state: "other"])
    conn = MyRouter.call(conn, @opts)
    openid = get_session(conn, :openid)

    assert openid == "openid"
    assert conn.assigns[:wechat_result] == %{openid: "openid"}
  end
end
