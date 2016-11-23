defmodule ExWechat.Helpers.MethodGenerator do
  @moduledoc """
    Generate AST method data base on api definition data.
  """
  alias HTTPoison.Response
  alias HTTPoison.Error

  @doc """
    Generate methods base on the api defintion data.
  """
  def generate_methods(origin) do
    origin |> do_generate_methods
  end


  # Generate the AST data fro the methods
  # [access_token: [get_access_token: [doc: _, endpoint: _ ...]], menu: [ ... ]]

  defp do_generate_methods(origin, result \\ [])
  defp do_generate_methods([], result), do: result
  defp do_generate_methods(origin, []) do
    do_generate_methods(origin, [define_helper_method])
  end
  defp do_generate_methods([{_key, value} | tail], result) do
    do_generate_methods(tail, result ++ define_request_method(value))
  end

  defp define_request_method(data, result \\ [])
  defp define_request_method([], result), do: result
  defp define_request_method([ {key, list} | tail], result) do
    [doc: doc, endpoint: endpoint, path: path,
      http: http, params: params] = list

    url = endpoint <> path
    ast_data = case http do
      :get  -> define_get_request_method(key,  url, doc, params)
      :post -> define_post_request_method(key, url, doc, params)
    end

    define_request_method(tail, result ++ [ast_data])
  end

  defp define_get_request_method(name, url, doc, params)  do
    quote do
      @doc unquote(doc)
      def unquote(name)(added_params \\ []) do
        unquote(url)
        |> ExWechat.Api.get(union_params(unquote(params), added_params))
        |> parse_response(unquote(name), added_params)
      end
    end
  end

  defp define_post_request_method(name, url, doc, params) do
    quote do
      @doc unquote(doc)
      def unquote(name)(body, added_params \\ []) do
        unquote(url)
        |> ExWechat.Api.post(body, union_params(unquote(params), added_params))
        |> parse_response(unquote(name), body, added_params)
      end
    end
  end

  #  All the helper method that will be used above.
  #
  #    - parse_response
  #    - union_params

  defp define_helper_method do
    quote do
      defp parse_response(response, name, body \\ nil, params)
      defp parse_response({:ok, %Response{body: %{errcode: 40001}}},
                           name, body, params) do
        module = __MODULE__
        module.renew_access_token
        case body do
          nil -> apply(module, name, [params])
          _   -> apply(module, name, [body, params])
        end
      end

      defp parse_response({:error, %Error{reason: :closed}},
                           name, body, params) do
        module = __MODULE__
        case body do
          nil -> apply(module, name, [params])
          _   -> apply(module, name, [body, params])
        end
      end
      defp parse_response({:error, error}, _, _, _) do
          %{error: error.reason}
      end
      defp parse_response({:ok, response}, _, _, _) do
        response.body |> process_body
      end

      defp process_body(body)
      defp process_body("{" <> _ = body) do
        Poison.decode!(body, keys: :atoms)
      end
      defp process_body(body), do: body

      defp union_params(params, added_params)
      defp union_params(nil, nil), do: []
      defp union_params(nil, added_params), do: added_params
      defp union_params(params, nil), do: params
      defp union_params(params, added_params) do
        params
        |> parse_params(__MODULE__)
        |> Keyword.merge(added_params)
      end
    end
  end
end
