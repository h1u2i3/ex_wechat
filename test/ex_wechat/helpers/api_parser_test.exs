defmodule ExWechat.Helpers.ApiParserTest do
  use ExUnit.Case, async: true

  alias ExWechat.Helpers.ApiHelper

  @doc """
  //---------------------
  //  access_token
  //---------------------

  @endpoint https://localhost

  # get the access_token from wechat server

  function: some_method
  path: /haha
  http: get
  params: grant_type=client_credential, appid, secret
  """

  test "should get the right parsed data" do
    %{demo: [data]} = ApiHelper.process_api_definition_data([:demo])

    assert data.endpoint == "https://localhost"
    assert data.function == :some_method
    assert data.path == "/haha"
    assert data.http == :get
    assert data.params == "grant_type=client_credential, appid, secret"
  end
end
