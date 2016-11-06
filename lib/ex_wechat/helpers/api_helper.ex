defmodule ExWechat.Helpers.ApiHelper do
  @moduledoc """
    praser data from api description file.
  """
  require Logger
  alias ExWechat.Api

  @base     "https://api.weixin.qq.com"
  @cgi_bin  "https://api.weixin.qq.com/cgi-bin"

  @api_endpoints %{
    access_token:   @cgi_bin,
    custom_service: @base,
    qrcode:         @cgi_bin,
    menu:           @cgi_bin,
    server_ip:      @cgi_bin,
    card:           @base,
    media:          @cgi_bin,
    message:        @cgi_bin,
    shorturl:       @cgi_bin,
    user:           @cgi_bin
  }

  def get_api_endpoint(url) do
    @api_endpoints[
      Enum.find_value(all_api_definition_data, fn({key, value})->
        case url_is_member_of_value(url, value) do
          true -> key
          false -> :access_token
        end
      end)
    ]
  end

  @doc """
    get the data from api definition file and praser it.
  """
  def api_definition(path) do
    File.stream!(path, [], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(String.length(&1) == 0))
      |> Stream.reject(&(String.starts_with?(&1, "#")))
      |> Enum.chunk(4)
  end

  @doc """
    fetch api definition data from the definition file.
  """
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

  @doc """
    make string to atom to get the param key.
    when string contains =, then get the params key.
  """
  def param_key(param) do
    case String.match?(param, ~r/=/) do
      true ->
        String.split(param, "=")
          |> List.first
          |> String.to_atom
      false ->
        String.to_atom(param)
    end
  end

  @doc """
    get the value of the param
    when the param string contains =, then split it to get the value.
  """
  def param_value(param) do
    case String.match?(param, ~r/=/) do
      true ->
        String.split(param, "=")
          |> List.last
      false ->
        apply(Api, String.to_atom(param), [])
    end
  end

  defp all_api_definition_data do
    for path <- Path.wildcard(Path.join(__DIR__, "../apis/*")), into: %{} do
      {path |> String.replace(__DIR__ <> "/../apis/", "") |> String.to_atom, path |> api_definition |> process_data}
    end
  end

  defp process_data(data) do
    case data do
      [] -> []
      _ ->  data
            |> Enum.map(fn([function, path, verb, params]) ->
                 [function_name(function), url_path(path), http_verb(verb), url_params(params)]
               end)
    end
  end

  defp url_is_member_of_value(url, value) do
    Enum.any?(value, fn(definition)->
      case definition do
        [_, ^url, _, _] -> true
        _               -> false
      end
    end)
  end

  defp url_path(path_string) do
    path_string
    |> split_colon
    |> List.last
  end

  defp http_verb(verb_string) do
    verb_string
    |> split_colon
    |> List.last
    |> String.to_atom
  end

  defp function_name(function_string) do
    function_string
    |> split_colon
    |> List.last
    |> String.to_atom
  end

  defp url_params(params_string) do
    params_string
    |> split_colon
    |> List.last
    |> split_comma
  end

  defp split_colon(string) do
    string
    |> String.split(":")
    |> Enum.map(&String.trim/1)
  end

  defp split_comma(string) do
    string
    |> String.split(~r/,/)
    |> Enum.map(&String.trim/1)
  end
end
