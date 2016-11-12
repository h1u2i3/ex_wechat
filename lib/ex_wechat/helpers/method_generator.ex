defmodule ExWechat.Helpers.MethodGenerator do
  def generate_methods(origin), do: origin |> to_keyword_list |> do_generate_methods

  defp do_generate_methods(origin, result \\ [])
  defp do_generate_methods([], result), do: result
  defp do_generate_methods(origin, []), do: do_generate_methods(origin, [define_helper_method])
  defp do_generate_methods([{_key, value} | tail], result), do: do_generate_methods(tail, result ++ define_api_method(value))

  defp to_keyword_list(map), do: Enum.map(map, fn({key, value}) -> {key, value} end)

  defp define_api_method(map), do: define_endpoint_method(map) ++ define_request_method(map)

  defp endpoint_method_name(path), do: "#{String.replace(path, "/", "_")}_url" |> String.to_atom

  defp define_endpoint_method(data, result \\ [])
  defp define_endpoint_method([], result), do: result
  defp define_endpoint_method([map | tail], result) do
    %{path: path, endpoint: endpoint} = map
    ast_data = quote do
      @doc false
      def unquote(endpoint_method_name(path))() do
        unquote(endpoint)
      end
      defoverridable Keyword.put([] ,unquote(endpoint_method_name(path)), 0)
    end
    define_endpoint_method(tail, result ++ [ast_data])
  end

  defp define_request_method(data, result \\ [])
  defp define_request_method([], result), do: result
  defp define_request_method([map | tail], result) do
    %{function: function, path: path, params: params, doc: doc, http: http} = map
    ast_data = case http do
      :get  -> define_get_request_method(http, function, path, doc, params)
      :post -> define_post_request_method(http, function, path, doc, params)
    end
    define_request_method(tail, result ++ [ast_data])
  end

  def define_get_request_method(http, function, path, doc, params)  do
    quote do
      @doc unquote(doc)
      def unquote(function)(added_params \\ []) do
        do_request(unquote(http), unquote(path), union_params(unquote(params), added_params))
        |> parse_response(unquote(function), added_params)
      end
      defoverridable Keyword.put([], unquote(function), 0)
      defoverridable Keyword.put([], unquote(function), 1)
    end
  end

  def define_post_request_method(http, function, path, doc, params) do
    quote do
      @doc unquote(doc)
      def unquote(function)(body, added_params \\ []) do
        do_request(unquote(http), unquote(path), body, union_params(unquote(params), added_params))
        |> parse_response(unquote(function), body, added_params)
      end
      defoverridable Keyword.put([], unquote(function), 1)
      defoverridable Keyword.put([], unquote(function), 2)
    end
  end

  defp define_helper_method do
    quote do
      defp do_request(http, path, body \\ nil, params)
      defp do_request(:get,  path, _   , params), do: __MODULE__.get(path, [], params: params)
      defp do_request(:post, path, body, params), do: __MODULE__.post(path, encode_post_body(body), [], params: params)

      defp parse_response(response, function, body \\ nil, params)
      defp parse_response({:ok, %HTTPoison.Response{body: %{errcode: 40001}} = response}, function, nil, params) do
        ExWechat.Token._force_get_access_token
        apply(__MODULE__, function, [params])
      end
      defp parse_response({:ok, %HTTPoison.Response{body: %{errcode: 40001}}}, function, body, params) do
        ExWechat.Token._force_get_access_token
        apply(__MODULE__, function, [body, params])
      end
      defp parse_response({:ok, %HTTPoison.Response{} = response}, _function, _body, _params) do
        response.body
      end
      defp parse_response({:error, %HTTPoison.Error{reason: :closed}}, function, nil, params) do
        apply(__MODULE__, function, [params])
      end
      defp parse_response({:error, %HTTPoison.Error{reason: :closed}}, function, body, params) do
        apply(__MODULE__, function, [body, params])
      end
      defp parse_response({:error, %HTTPoison.Error{} = error}, _function, _body, _params), do: %{error: error.reason}

      defp union_params(params_string, added_params), do: params_string |> parse_params(__MODULE__) |> Keyword.merge(added_params)

      defp encode_post_body(body)
      defp encode_post_body(body) when is_map(body), do: Poison.encode!(body)
      defp encode_post_body(body) when is_binary(body), do: body
      defp encode_post_body(nil), do: nil
    end
  end
end
