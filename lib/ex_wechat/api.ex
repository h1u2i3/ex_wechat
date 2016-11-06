defmodule ExWechat.Api do
  @moduledoc """
    Generate api methods base on the api definitions.
    You also can `use` it to import all the api methods.

        use ExWechat.Api
        @api [:access_token]  # just import the method in `access_token` definition
        @api :all             # import all the method

    then you can test the method it in your termnal.
    if you don't add the `@api` attribute, it will import all the api methods.

    All the methods in definition file are like this:

        #---------------------
        #  access_token
        #---------------------
        # get the access_token
        function: get_access_token
        path: /token
        http: get
        params: grant_type=client_credential, appid, secret

    and each method is a `get` or `post` http method.

        # post method
        create_menu(post_body, extra_params \\ [])
        # get method
        get_menu(extra_params \\ [])

    When use a `post` method, it is you responsibility to offer the right data.
  """

  use HTTPoison.Base
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
    Process_response_body is override from `HTTPoison.Base`, this function is to convert json response to Elixir map.
  """
  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
  end

  @doc """
    Generate all the methods define in the api definitions.
  """
  def define_api_method([name, path, verb, params]) do
    case verb do
      :get ->
        quote do
          def unquote(name)(added_params \\ []) do
            case unquote(__MODULE__).get(unquote(path), [],
              params: unquote(__MODULE__).make_params(unquote(params), added_params)) do
                {:ok, response} ->
                  response.body
                {:error, error} ->
                  %{error: error.reason}
            end
          end
        end
      :post ->
        quote do
          def unquote(name)(post_body, added_params \\ []) do
            case unquote(__MODULE__).post!(unquote(path), Poison.encode!(post_body), [],
              params: unquote(__MODULE__).make_params(unquote(params), added_params)) do
                {:ok, response} ->
                  response.body
                {:error, error} ->
                  %{error: error.reason}
            end
          end
        end
    end
  end

  @doc """
    Merge the `added_params` into params.
  """
  def make_params(params, added_params) do
    params = List.delete(params, "")
    case Enum.empty?(params) do
      true  ->
        []
      false ->
        params
        |> Enum.reduce([], fn(param, acc) ->
             Keyword.put(acc, param_key(param), param_value(param))
           end)
        |> Keyword.merge(added_params)
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

  defp process_url(url) do
    ExWechat.Helpers.ApiHelper.get_api_endpoint(url) <> url
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api)
    |> process_api_definition_data
    |> compile
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end
end
