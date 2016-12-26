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
  defmacro __using__(config) do
    base_method_ast =
      quoted_base_method(config)

    quote do
      alias ExWechat.Token
      import ExWechat.Helpers.ParamsParser

      @before_compile unquote(__MODULE__)

      unquote(base_method_ast)

      unquote(params_method)
      unquote(all_token_methods)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:api)
    |> process_api_definition_data
    |> compile
  end

  defp compile(origin) do
    ast_data = generate_methods(origin)

    quote do
      unquote(ast_data)
    end
  end

  defp all_token_methods do
    for token_type <- [:access_token, :jsapi_ticket, :wxcard_ticket] do
      quote do
        @doc """
        Get the #{unquote(token_type)}
        """
        def unquote(token_type)() do
          apply(Token, :"_#{unquote(token_type)}", [__MODULE__])
        end

        @doc """
        Renew the #{unquote(token_type)}
        """
        def unquote(:"renew_#{token_type}")() do
          apply(Token, :"_force_get_token", [__MODULE__, unquote(token_type)])
        end
      end
    end
  end

  defp params_method do
    quote do
      @doc """
      This method can be used in you own defined module.
      You can add this method in your module and afford the needed params.
      """
      def get_params(param) do
        :not_set
      end
      defoverridable [get_params: 1]
    end
  end
end
