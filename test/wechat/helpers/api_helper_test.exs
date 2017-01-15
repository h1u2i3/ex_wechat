defmodule Wechat.Helpers.ApiHelperTest do
  use ExUnit.Case, async: true
  use Wechat.Base
  import Wechat.Helpers.ApiHelper

  test "should get all the api data from the api definition file" do
    all_data = api_data(:all)
    path = Path.join(__DIR__, "../../../lib/wechat/core/apis")

    all_file_keys = get_file_keys(path)

    assert all_file_keys == Keyword.keys(all_data) |> Enum.sort
  end

  test "should get all the api data when use nil" do
    all_data = api_data(:all)
    nil_data = api_data(nil)

    assert all_data == nil_data
  end

  test "should only get the specific api data" do
    assert :access_token in Keyword.keys(api_data([:access_token]))
  end

  defp get_file_keys(path) do
    grab_string = path <> "/*"
    grab_string
    |> Path.wildcard
    |> Enum.map(fn(path) ->
         path
         |> Path.basename(".exs")
         |> String.to_atom
       end)
  end
end
