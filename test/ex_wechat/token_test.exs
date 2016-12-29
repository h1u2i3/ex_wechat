defmodule ExWechat.TokenTest do
  use ExUnit.Case, async: true

  alias ExWechat.Tools.HttpCase

  defmodule Demo do
    use ExWechat.Api
  end

  @cache ExWechat.Token.Cache
  @module ExWechat.TokenTest.Demo

  @data %{access_token: "token", expire_in: "7200"}


  test "expect get the data from server" do
    HttpCase.fake @data
    assert @data == Demo.get_access_token
  end

  test "get access_token should write to cache" do
    del_access_token_cache()

    HttpCase.fake(@data)
    access_token = Demo.access_token
    cache =
      @cache
      |> Agent.get(&(Map.get(&1, {@module, :access_token})))
      |> elem(0)

    assert access_token == cache
  end

  test "when cache exists should read from cache" do
    prepare_for_access_token_cache("token")

    HttpCase.fake(@data)
    access_token = Demo.access_token

    refute access_token == "bad_token"
    assert access_token == "token"
  end

  test "force get access_token will get the new access_token" do
    prepare_for_access_token_cache("token")

    HttpCase.fake %{access_token: "new_token", expire_in: "7200"}
    access_token = Demo.renew_access_token

    assert access_token == "new_token"
  end

  defp del_access_token_cache do
    Agent.update @cache, fn _ -> %{} end
  end

  defp prepare_for_access_token_cache(data) do
    del_access_token_cache()
    Agent.update @cache, fn _ ->
      %{{@module, :access_token} => {data, System.os_time(:seconds)}}
    end
  end
end
