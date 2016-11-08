defmodule ExWechat.Api do
  @moduledoc """
    Generate api methods base on the api definitions.
    You also can `use` it to import all the api methods.

        use ExWechat.Api
        @api [:access_token]  # just import the method in `access_token` definition
        @api :all             # import all the method

    then you can test the method it in your termnal.
    if you don't add the `@api` attribute, it will import all the api methods.
  """

  use ExWechat.Base

  import ExWechat.Helpers.ApiHelper
  alias ExWechat.Token

  @doc """
    Return the access_token
  """
  def access_token do
    Token._access_token
  end

  @doc """
    Use when access_token invalid
  """
  def renew_access_token do
    Token._force_get_access_token
  end

  @doc false
  def encode_post_body(body) do
    case body do
      %{} -> Poison.encode!(body)
      _   -> body
    end
  end

  @doc """
    Generate all the methods define in the api definitions.
  """
  def define_api_method(%{endpoint: endpoint, params: params, http: http,
                         path: path, function: function, doc: doc}) do
    case http do
      :get ->
        quote do
          @doc false
          def unquote((String.replace(path, "/", "_") <> "url") |> String.to_atom)() do
            unquote(endpoint)
          end

          @doc """
            #{unquote(doc)}
          """
          def unquote(function)(added_params \\ []) do
            case __MODULE__.get(unquote(path), [],
              params: unquote(params)
                      |> unquote(__MODULE__).do_parse_params([], "", "")
                      |> Keyword.merge(added_params)) do
                {:ok, response} ->
                  body = response.body
                  case body do
                    %{errcode: 40001} ->
                      unquote(__MODULE__).renew_access_token
                      apply(__MODULE__, unquote(function), [added_params])
                    _ ->  body
                  end
                {:error, error} ->
                  case error.reason do
                    :closed ->
                      apply(__MODULE__, unquote(function), [added_params])
                    _  ->
                      %{error: error.reason}
                  end
            end
          end
        end
      :post ->
        quote do
          @doc false
          def unquote((String.replace(path, "/", "_") <> "url") |> String.to_atom)() do
            unquote(endpoint)
          end

          @doc """
            #{unquote(doc)}
          """
          def unquote(function)(post_body, added_params \\ []) do
            case __MODULE__.post(unquote(path), unquote(__MODULE__).encode_post_body(post_body), [],
              params: unquote(params)
                      |> unquote(__MODULE__).do_parse_params([], "", "")
                      |> Keyword.merge(added_params)) do
                {:ok, response} ->
                  body = response.body
                  case body do
                    %{errcode: 40001} ->
                      unquote(__MODULE__).renew_access_token
                      apply(__MODULE__, unquote(function), [post_body, added_params])
                    _ ->  body
                  end
                {:error, error} ->
                  case error.reason do
                    :closed ->
                      apply(__MODULE__, unquote(function), [post_body, added_params])
                    _  ->
                      %{error: error.reason}
                  end
            end
          end
        end
    end
  end

  @doc """
    Generate the AST data of method definiitons.
  """
  def compile(origin) do
    values = origin
           |> Map.values
           |> Enum.reject(&Enum.empty?/1)
           |> Enum.flat_map(fn(x) ->
                case x do
                  [[[head | tail]]] -> [head | tail]
                  _ -> x
                end
              end)

    ast_data = for data <- values do
      define_api_method(data)
    end

    quote do
      unquote(ast_data)
    end
  end



  @doc false
  def do_parse_params(params, result, key, value)
  def do_parse_params("", result, "", "") do
    result
  end
  def do_parse_params("=" <> rest, result, key, value) do
    result = result |> Keyword.put(key |> String.to_atom, value)
    do_parse_params(rest, result, key, value)
  end
  def do_parse_params(", " <> rest, result, key, "") do
    key = key |> String.to_atom
    result = result |> Keyword.put(key, apply(ExWechat.Api, key, []))
    do_parse_params(rest, result, "", "")
  end
  def do_parse_params(", " <> rest, result, key, value) do
    key = key |> String.to_atom
    result = result |> Keyword.put(key, value)
    do_parse_params(rest, result, "", "")
  end
  def do_parse_params(<<binary::8>> <> rest, result, key, value) do
    case Keyword.has_key?(result, String.to_atom(key)) do
      false ->
        do_parse_params(rest, result, key <> IO.chardata_to_string([binary]), "")
      true ->
        do_parse_params(rest, result, key, value <> IO.chardata_to_string([binary]))
    end
  end
  def do_parse_params("", result, key, value) do
    do_parse_params(", ", result, key, value)
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api)
    |> process_api_definition_data
    |> compile
  end

  defmacro __using__(_opts) do
    quote do
      use HTTPoison.Base
      @before_compile unquote(__MODULE__)

      @doc false
      def process_response_body(body) do
        Poison.decode!(body, keys: :atoms)
      end

      @doc false
      def process_url(url) do
        path = url |> String.split("?") |> List.first
        endpoint = apply __MODULE__, (String.replace(path, "/", "_") <> "url") |> String.to_atom, []
        endpoint <> url
      end
    end
  end
end
