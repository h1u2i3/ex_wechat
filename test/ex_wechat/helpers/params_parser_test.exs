defmodule ExWechat.Helpers.ParamsParserTest do
  use ExUnit.Case, async: true

  import ExWechat.Helpers.ParamsParser

  defmodule Demo do
    use ExWechat.Api
  end

  test "should get [] when params is empty" do
    assert [] = parse_params([])
  end

  test "should get right params when has value" do
    assert [some: "value"] == parse_params([some: "value"])
  end

  test "should get right value in ExWechat.Base" do
    assert [appid: "yourappid", secret: "yourappsecret", token: "yourtoken"] ==
      parse_params([appid: nil, secret: nil, token: nil])
  end

  test "should get :no_set when there is no method in api" do
    assert [special: :not_set] == parse_params([special: nil], Demo)
  end
end
