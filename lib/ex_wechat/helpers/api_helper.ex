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
    do_parse_api_data(%{}, [], data)
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
  defp do_parse_api_data(temp, result, endpoint \\ nil, lines)
  defp do_parse_api_data(temp, result, endpoint, [ "//"  <> _     | tail ]) do
    do_parse_api_data(temp, result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "# "  <> rest  | tail ]) do
    {_, temp} = Map.get_and_update(temp, :doc, fn(current) ->
      case current do
        nil ->  {current, rest}
        _   ->  {current, current <> "\n" <> rest}
      end
    end)
    do_parse_api_data(temp, result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "@endpoint " <> rest | tail ]) do
    temp = temp |> Map.put(:endpoint, rest |> String.trim)
    case endpoint do
      nil  ->  do_parse_api_data(temp, result, rest, tail)
      _    ->  do_parse_api_data(temp, result, endpoint, tail)
    end
  end
  defp do_parse_api_data(temp, result, endpoint, [ "function: " <> rest | tail ]) do
    temp
    |> Map.put(:function, rest |> String.trim |> String.to_atom)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "path: " <> rest | tail ]) do
    temp
    |> Map.put(:path, rest |> String.trim)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "http: " <> rest | tail ]) do
    temp
    |> Map.put(:http, rest |> String.trim |> String.to_atom)
    |> do_parse_api_data(result, endpoint, tail)
  end
  defp do_parse_api_data(temp, result, endpoint, [ "params:" <> rest | tail ]) do
    temp = case Map.get(temp, :endpoint) do
             nil ->
               temp
               |> Map.put(:endpoint, endpoint)
               |> Map.put(:params, rest |> String.trim)
             _   ->
               temp
               |> Map.put(:params, rest |> String.trim)
           end
    do_parse_api_data(%{}, result ++ [temp], endpoint, tail)
  end
  defp do_parse_api_data(_temp, result, _, []) do
    result
  end
end
