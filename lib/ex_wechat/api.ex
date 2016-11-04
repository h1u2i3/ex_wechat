defmodule ExWechat.Api do
  use HTTPoison.Base

  import ExWechat.Api.Helper
  alias ExWechat.Token

  @endpoint "https://api.weixin.qq.com/cgi-bin"

  def access_token do
    Token._access_token
  end

  def process_response_body(body) do
    Poison.decode!(body, keys: :atoms)
  end

  def define_api_method(origin) do
    for [name, path, verb, params] <- origin do
      case verb do
        :get ->
          quote do
            def unquote(name)() do
              unquote(__MODULE__).get!(unquote(path), [], params: Enum.reduce(unquote(params), [], fn(param, acc) ->
                Keyword.put(acc, param_key(param), param_value(param))
              end)).body
            end
          end
        :post ->
          quote do
            def unquote(name)(post_body) do
              unquote(__MODULE__).post!(unquote(path), [post_body], params: Enum.reduce(unquote(params), [], fn(param, acc) ->
                Keyword.put(acc, param_key(param), param_value(param))
              end)).body
            end
          end
      end
    end
  end

  def compile(origin) do
    ast_data = define_api_method(origin)
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
