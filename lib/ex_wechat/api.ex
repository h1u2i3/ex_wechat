defmodule ExWechat.Api do
  @moduledoc """
    Generate api methods base on the api definitions.
    You also can `use` it to import all the api methods.

        use ExWechat.Api
        @api [:access_token]  # just import the method in `access_token` definition
        @api :all             # import all the method

    If you didn't add the `@api` attribute, it will import all the api methods.
  """

  use ExWechat.Base

  import ExWechat.Helpers.ApiHelper
  import ExWechat.Helpers.MethodGenerator

  alias ExWechat.Token

  @doc """
    Return the access_token
  """
  def access_token, do: Token._access_token

  @doc """
    Use when access_token invalid
  """
  def renew_access_token, do: Token._force_get_access_token

  @doc """
    Generate the AST data of method definiitons.
  """
  def compile(origin) do
    ast_data = generate_methods(origin)

    quote do
      unquote(ast_data)
    end
  end

  defmacro __using__(_opts) do
    quote do
      use HTTPoison.Base

      import ExWechat.Helpers.ParamsParser

      @before_compile unquote(__MODULE__)

      defp process_response_body(body)
      defp process_response_body("{" <> _ = body), do: Poison.decode!(body, keys: :atoms)
      defp process_response_body(body), do: body

      defp process_url(url) do
        apply(__MODULE__, url_method_name(url), []) <> url
      end

      defp url_method_name(url) do
        "#{Regex.named_captures(~r/(?<name>.+)\?/, url)["name"]}/url"
        |> String.replace("/", "_")
        |> String.to_atom
      end
    end
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api)
    |> process_api_definition_data
    |> compile
  end
end
