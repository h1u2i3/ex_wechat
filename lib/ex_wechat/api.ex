defmodule ExWechat.Api do
  @moduledoc """
    Generate api methods base on the api definitions.
    You also can `use` it to import all the api methods.

        use ExWechat.Api

        # just import the method in `access_token` definition
        @api [:access_token]

        # import all the method
        @api :all

    If you didn't add the `@api` attribute, it will import all the api methods.
  """
  use ExWechat.Base

  import ExWechat.Base
  import ExWechat.Helpers.ApiHelper
  import ExWechat.Helpers.MethodGenerator

  @doc false
  def get_params(key, module) do
    apply module, :get_params, [key]
  end

  @doc false
  def compile(origin) do
    ast_data = generate_methods(origin)

    quote do
      unquote(ast_data)
    end
  end

  @doc """
  Do http get request with HTTPoison.
  """
  def get(url, params) do
    ensure_httpoison_start
    HTTPoison.get(url, [], params: params)
  end

  @doc """
  Do http post request with HTTPoison.
  """
  def post(url, body, params) do
    ensure_httpoison_start
    HTTPoison.post(url, encode_post_body(body), [], params: params)
  end

  defp ensure_httpoison_start, do: :application.ensure_all_started(:httpoison)

  defp encode_post_body(body)
  defp encode_post_body(nil), do: nil
  defp encode_post_body(body) when is_binary(body), do: body
  defp encode_post_body(body) when is_map(body), do: Poison.encode!(body)

  defmacro __using__(config) do
    base_method_ast = quoted_base_method(config)

    quote do
      alias ExWechat.Token
      import ExWechat.Helpers.ParamsParser

      @before_compile unquote(__MODULE__)

      unquote(base_method_ast)

      @doc """
        This method can be used in you own defined module.
        You can add this method in your module and afford the needed params.
      """
      def get_params(param) do
        :not_set
      end
      defoverridable [get_params: 1]

      @doc """
        Return the access_token
      """
      def access_token, do: Token._access_token(__MODULE__)

      @doc """
        When error code 400001, renew access_token
      """
      def renew_access_token, do: Token._force_get_access_token(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api)
    |> process_api_definition_data
    |> compile
  end
end
