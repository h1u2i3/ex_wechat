defmodule ExWechat.TestHelper.Http do
  @moduledoc """
    Http mock expect method.
  """

  use ExWechat.Base

  defmacro __using__(_) do
    quote do
      import :meck

      def expect_response(:get, result) do
        expect(ExWechat.Http, :get, 2, result)
        # expect(:hackney,
        #        :request,
        #        [{ [:get, "#{url}?#{params_url(params)}", [], "",
        #           [pool: :wechat_pool]],
        #           {:ok, 200, "headers", :client} }])
        # expect(:hackney, :body, 1, {:ok, encode(result)})
      end
      def expect_response(:post, result) do
        expect(ExWechat.Http, :get, 2, result)
        # expect(:hackney,
        #        :request,
        #        [{ [:post, "#{url}?#{params_url(params)}", [], encode(body),
        #           [pool: :wechat_pool]],
        #           {:ok, 200, "headers", :client} }])
        # expect(:hackney, :body, 1, {:ok, encode(result)})
      end

      defp params_url(params) do
        params
        |> Enum.sort
        |> Enum.map(fn({key, value}) ->
             "#{key}=#{value}"
           end)
        |> Enum.join("&")
      end

      defp encode(body)
      defp encode(body) when is_binary(body), do: body
      defp encode(body) when is_map(body), do: Poison.encode!(body)
      defp encode(nil), do: ""
    end
  end
end
