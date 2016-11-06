defmodule ExWechat.Api do
  use HTTPoison.Base
  use ExWechat.Base

  import ExWechat.Helpers.ApiHelper
  alias ExWechat.Token

  @endpoint "https://api.weixin.qq.com/cgi-bin"

  def access_token do
    Token._access_token
  end

  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
  end

  def define_api_method([name, path, verb, params]) do
    case verb do
      :get ->
        quote do
          def unquote(name)(added_params \\ []) do
            unquote(__MODULE__).get!(unquote(path), [],
              params: unquote(__MODULE__).make_params(unquote(params), added_params)).body
          end
        end
      :post ->
        quote do
          def unquote(name)(post_body, added_params \\ []) do
            unquote(__MODULE__).post!(unquote(path), Poison.encode!(post_body), [],
              params: unquote(__MODULE__).make_params(unquote(params), added_params)).body
          end
        end
    end
  end

  def make_params(params, added_params) do
    params
    |> Enum.reduce([], fn(param, acc) ->
         Keyword.put(acc, param_key(param), param_value(param))
       end)
    |> Keyword.merge(added_params)
  end

  def compile(origin) do
    ast_data = for method_data <- origin do
      define_api_method(method_data)
    end
    quote do
      unquote(ast_data)
    end
  end


  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api_methods)
    |> process_api_data
    |> compile
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defp process_url(url) do
    @endpoint <> url
  end
end
