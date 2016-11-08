defmodule ExWechat.Helpers.ApiHelper do
  @moduledoc """
    praser data from api description file.
  """
  use ExWechat.Base

  def process_api_definition_data(needed_api_kinds) do
    case needed_api_kinds do
      nil ->
        process_api_definition_data(:all)
      :all ->
        all_api_definition_data
      _ ->
        Map.take(all_api_definition_data, needed_api_kinds)
    end
  end

  # read single file and return api definition data
  defp api_definition_data(path) do
    data = File.stream!(path, [], :line)
           |> Stream.map(&String.trim/1)
           |> Stream.reject(&(String.length(&1) == 0))
           |> Enum.to_list
    do_parse_api_data([], [], data)
  end

  # get all the data of all the api definition file
  defp all_api_definition_data do
    all_definition_files =  case api_definition_files do
                              nil -> Path.wildcard(Path.join(__DIR__, "../apis/*"))
                              _   -> Path.wildcard(Path.join(__DIR__, "../apis/*")) ++ Path.wildcard(api_definition_files <> "/*")
                            end
    for path <- all_definition_files, into: %{} do
      {path |> String.split("/") |> List.last |> String.to_atom, path |> api_definition_data}
    end
  end

  # parse data from api definition file with parttern match
  defp do_parse_api_data(temp, result, endpoint \\ "", lines)
  defp do_parse_api_data(temp, result, endpoint, [ "//"  <> _    | tail ]) do
    do_parse_api_data(temp, result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "# " <> rest | tail ]) do
    {_, temp} = Keyword.get_and_update(temp, :doc, fn(current) ->
      case current do
        nil ->  {current, rest}
        _   ->  {current, current <> "\n" <> rest}
      end
    end)
    do_parse_api_data(temp, result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, _, [ "@endpoint " <> rest | tail ]) do
    do_parse_api_data(temp, result, String.trim(rest), tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "function: " <> rest | tail ]) do
    temp
    |> Keyword.put(:function, rest |> String.trim |> String.to_atom)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "path: " <> rest | tail ]) do
    temp
    |> Keyword.put(:path, rest |> String.trim)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "http: " <> rest | tail ]) do
    temp
    |> Keyword.put(:http, rest |> String.trim |> String.to_atom)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "params: " <> rest | tail ]) do
    params = rest |> String.trim
    temp = temp
           |> Keyword.put(:params, params)
           |> Keyword.put(:endpoint, endpoint)
    do_parse_api_data([], result ++ [temp], endpoint,tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "params:" | tail ]) do
    temp = temp
           |> Keyword.put(:params, "")
           |> Keyword.put(:endpoint, endpoint)
    do_parse_api_data([], result ++ [temp], endpoint, tail)
  end
  defp do_parse_api_data(_temp, result, _, []) do
    result
  end
end
