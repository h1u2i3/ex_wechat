defmodule ExWechat.Helpers.ApiHelperTest do
  use ExUnit.Case, async: true

  import ExWechat.Helpers.ApiHelper

  test "should get all the api data from the api definition file" do
    all_data = process_api_definition_data(:all)
    path = Path.join(__DIR__, "../../../lib/ex_wechat/apis")

    all_file_keys = get_file_keys(path)
    user_define_file_keys = get_file_keys(api_definition_files)
    all_keys = Enum.sort(all_file_keys ++ user_define_file_keys)

    assert all_keys == Map.keys(all_data)
  end

  test "should get all the api data when use nil" do
    all_data = process_api_definition_data(:all)
    nil_data = process_api_definition_data(nil)

    assert all_data == nil_data
  end

  test "should only get the specific api data" do
    assert %{access_token: _data} = process_api_definition_data([:access_token])
  end

  test "should get user specific api data" do
    assert %{demo: _} = process_api_definition_data(:all)
  end

  defp get_file_keys(path) do
    grab_string = path <> "/*"
    grab_string
    |> Path.wildcard
    |> Enum.map(fn(file) ->
         key_string = String.split(file, "/")
         key_string |> List.last |> String.to_atom
       end)
  end
end
