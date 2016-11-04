defmodule ExWechat.Api.Helper do
  alias ExWechat.Api

  def api_data do
    File.stream!(Path.join([__DIR__, "demo"]), [], :line)
      |> Stream.map(&String.strip/1)
      |> Stream.reject(&(String.length(&1) == 0))
      |> Stream.reject(&(String.starts_with?(&1, "#")))
      |> Stream.chunk(4)
  end

  def process_api_data(needed_api_methods) do
    processed_data = api_data
      |> Stream.map(fn([function, path, verb, params]) ->
          [function_name(function), url_path(path), http_verb(verb), url_params(params)]
        end)
    case needed_api_methods do
      :all ->
        processed_data
      _ ->
        Stream.reject(processed_data, fn([function, _, _, _]) ->
          !Enum.member?(needed_api_methods, function)
        end)
    end
  end

  def url_path(path_string) do
    path_string
    |> split_colon
    |> List.last
  end

  def http_verb(verb_string) do
    verb_string
    |> split_colon
    |> List.last
    |> String.to_atom
  end

  def function_name(function_string) do
    function_string
    |> split_colon
    |> List.last
    |> String.to_atom
  end

  def url_params(params_string) do
    params_string
    |> split_colon
    |> List.last
    |> split_comma
  end

  def split_colon(string) do
    string
    |> String.split(":")
    |> Enum.map(&String.strip/1)
  end

  def split_comma(string) do
    string
    |> String.split(~r{,})
    |> Enum.map(&String.strip/1)
  end

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

  def param_value(param) do
    case String.match?(param, ~r/=/) do
      true ->
        String.split(param, "=")
          |> List.last
      false ->
        apply(Api, String.to_atom(param), [])
    end
  end
end
