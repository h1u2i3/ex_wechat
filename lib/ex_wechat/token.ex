defmodule ExWechat.Token do
  use ExWechat.Api
  use ExWechat.Base
  import ExWechat.Utils.Time

  @api_methods [:get_access_token]

  @doc """
    first get the token from cache, if invalid then get from the wechat server.
    use Wechat.Api to get access_token from wechat server.
    or maybe we should try to use Agent or ETS to save the access_token
  """
  def _access_token do
    case File.stat(access_token_cache) do
      {:ok, %File.Stat{mtime: mtime}} ->
        access_token_generate_time = erl_datetime_to_unix_time(mtime)
        if access_token_valid?(access_token_generate_time) do
          read_access_token_from_cache
        else
          fetch_access_token_and_write_cache
        end
      {:error, _} ->
        fetch_access_token_and_write_cache
    end
  end

  defp read_access_token_from_cache do
    {:ok, access_token} = File.read(access_token_cache)
    access_token
  end

  defp fetch_access_token_and_write_cache do
    token = get_access_token.access_token
    File.write access_token_cache, token
    token
  end

  defp access_token_valid?(timestamp) do
    current_unix_time - timestamp < 7190
  end
end
