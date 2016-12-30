defmodule ExWechat.Http do
  @moduledoc """
  Http request module

  Try to make test easy.
  """

  for verb <- [:get, :post] do
    @doc """
    Do http #{verb} request with HTTPoison.
    Use a callback method to parse the reponse, and controll the error handling
    """
    def unquote(verb)(options, callback \\ &(&1)) do
      url    = options[:url]
      body   = options[:body]
      params = options[:params]

      http_case_fun =
        Application.get_env(:ex_wechat, :http_case)
      do_http_case =
        cond do
          is_function(http_case_fun) -> http_case_fun
          true -> &(&1)
        end

      case unquote(verb) do
        :get ->
          HTTPoison.get(url, [], gen_opts(params))
        :post ->
          HTTPoison.post(url, encode_post_body(body), [], gen_opts(params))
      end
      |> do_http_case.()
      |> callback.()
    after
      Application.delete_env(:ex_wechat, :http_case)
    end
  end

  @doc """
  Parse responde body, define for api, able to re-run the api functions.
  """
  def parse_response({:error, error}, _, _, _, _), do: %{error: error.reason}
  def parse_response({:ok, response}, _, _, _, _), do: response.body |> process_body

  @doc """
  Parse body for wechat site plug
  """
  def parse_wechat_site({:error, error}), do: %{error: error.reason}
  def parse_wechat_site({:ok, response}), do: response.body |> process_body

  defp gen_opts(params) do
    [params: params, hackney: [pool: :wechat_pool]]
  end

  defp process_body("{" <> _ = body), do: Poison.decode!(body, keys: :atoms)
  defp process_body(body), do: body

  # encode post request body
  defp encode_post_body(nil), do: nil
  defp encode_post_body(body) when is_binary(body), do: body
  defp encode_post_body(body) when is_map(body), do: Poison.encode!(body)
end
