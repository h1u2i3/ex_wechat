defmodule Wechat.Auth do
  alias Wechat.Http

  @api_endpoint "https://api.weixin.qq.com"

  @api_path "/sns/oauth2/access_token"
  @miniapp_path "/sns/jscode2session"
  @userinfo_path "/sns/userinfo"

  def info(code, options) do
    callback = &Http.parse_wechat_site/1

    # fetch for openid
    result = Http.get(request_auth_opts(code, options), callback)

    case result do
      %{errcode: _code} ->
        {:error, "bad code or code has been used"}

      _ ->
        if options[:scope] == "snsapi_base" do
          {:ok, result}
        else
          {:ok, Http.get(request_info_opts(result), callback)}
        end
    end
  end

  def miniapp_info(code, options) do
    callback = &Http.parse_wechat_site/1

    # fetch for openid
    result = Http.get(request_miniapp_opts(code, options), callback)

    case result do
      %{errcode: _code} = error ->
        {:error, "error: #{inspect(error)}"}

      _ ->
        {:ok, result}
    end
  end

  def miniapp_cellphone(code, options) do
    callback = &Http.parse_wechat_site/1

    # fetch for openid
    result = Http.get(request_miniapp_opts(code, options), callback)

    case result do
      %{errcode: _code} = error ->
        {:error, "error: #{inspect(error)}"}

      _ ->
        %{openid: openid, session_key: session_key} = result
        %{encrypted_data: encrypted_data, iv: iv} = options
        api = options[:api] || Wechat.Api
        appid = apply(api, :appid, [])

        case get_encrypted_info(appid, encrypted_data, iv, session_key) do
          {:ok, %{purePhoneNumber: cellphone}} ->
            {:ok, %{openid: openid, cellphone: cellphone}}

          {:error, _} ->
            {:error, "bad code or code has been used"}
        end
    end
  end

  defp request_miniapp_opts(code, options) do
    api = options[:api] || Wechat.Api
    appid = apply(api, :appid, [])
    secret = apply(api, :secret, [])

    [
      url: miniapp_url(),
      params: [appid: appid, secret: secret, js_code: code, grant_type: "authorization_code"]
    ]
  end

  defp request_auth_opts(code, options) do
    api = options[:api] || Wechat.Api
    appid = apply(api, :appid, [])
    secret = apply(api, :secret, [])

    [
      url: api_url(),
      params: [appid: appid, secret: secret, code: code, grant_type: "authorization_code"]
    ]
  end

  defp request_info_opts(result) do
    [
      url: userinfo_url(),
      params: [access_token: result.access_token, openid: result.openid, lang: "zh_CN"]
    ]
  end

  defp api_url do
    @api_endpoint <> @api_path
  end

  defp userinfo_url do
    @api_endpoint <> @userinfo_path
  end

  defp miniapp_url do
    @api_endpoint <> @miniapp_path
  end

  defp get_encrypted_info(appid, encrypted_data, iv, session_key) do
    encode_buffer = Base.decode64!(encrypted_data)
    encode_key = Base.decode64!(session_key)
    encode_iv = Base.decode64!(iv)

    result =
      try do
        :aes_128_cbc
        |> :crypto.block_decrypt(encode_key, encode_iv, encode_buffer)
        |> unpad_pkcs7
        |> Jason.decode!(keys: :atoms)
      catch
        _ ->
          nil
      end

    case result do
      %{watermark: %{appid: ^appid}} ->
        {:ok, result}

      _ ->
        {:error, "decrypt error happend"}
    end
  end

  defp unpad_pkcs7(string) do
    string
    |> String.reverse()
    |> do_unpad()
    |> String.reverse()
  end

  defp do_unpad(<<1>> <> result), do: result
  defp do_unpad(<<2, 2>> <> result), do: result
  defp do_unpad(<<3, 3, 3>> <> result), do: result
  defp do_unpad(<<4, 4, 4, 4>> <> result), do: result
  defp do_unpad(<<5, 5, 5, 5, 5>> <> result), do: result
  defp do_unpad(<<6, 6, 6, 6, 6, 6>> <> result), do: result
  defp do_unpad(<<7, 7, 7, 7, 7, 7, 7>> <> result), do: result
  defp do_unpad(<<8, 8, 8, 8, 8, 8, 8, 8>> <> result), do: result
end
