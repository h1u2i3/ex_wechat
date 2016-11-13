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

  import ExWechat.Helpers.ApiHelper
  import ExWechat.Helpers.MethodGenerator

  alias ExWechat.Token

  @doc """
    Return the access_token
  """
  def access_token, do: Token._access_token

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

      @doc """
        This method can be used in you own defined module.
        You can add this method in your module and afford the needed params.
      """
      def get_params(param) do
        :not_set
      end
      defoverridable [get_params: 1]

      defp process_response_body(body)
      defp process_response_body("{" <> _ = body) do
        Poison.decode!(body, keys: :atoms)
      end
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
