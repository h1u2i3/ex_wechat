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
    origin |> do_gen_methods
  end


  # Generate the AST data fro the methods
  # [access_token: [get_access_token: [doc: _, endpoint: _ ...]], menu: [ ... ]]
  defp do_gen_methods(origin) do
    main_methods =
      Enum.map origin, fn({_, value}) ->
        define_request_method(value)
      end

    helper_methods =
      define_helper_method

    quote do
      unquote(helper_methods)
      unquote(main_methods)
    end
  end

  defp define_request_method(data) do
    Enum.map data, fn({key, list}) ->
      [doc: doc, endpoint: endpoint, path: path, http: http, params: params] = list
      opts = [url: endpoint <> path, params: params]
      gen_request_method(http, key, doc, opts)
    end
  end

  defp gen_request_method(verb, name, doc, opts) do
    case verb do
      :get  -> gen_get_request_method(verb, name, doc, opts)
      :post -> gen_post_request_method(verb, name, doc, opts)
    end
  end

  defp gen_get_request_method(verb, name, doc, opts) do
    [url: url, params: params] = opts

    quote do
      @doc unquote(doc)
      def unquote(name)(extra \\ []) do
        name  = unquote(name)
        verb  = unquote(verb)
        url   = unquote(url)
        params   = union_params(unquote(opts[:params]), extra)
        callback = &ExWechat.Http.parse_response(&1, __MODULE__, name, nil, params)

        apply(ExWechat.Http, verb, [[url: url, params: params], callback])
      end
    end
  end

  defp gen_post_request_method(verb, name, doc, opts) do
    [url: url, params: params] = opts

    quote do
      @doc unquote(doc)
      def unquote(name)(body, extra \\ []) do
        name  = unquote(name)
        verb  = unquote(verb)
        url   = unquote(url)
        params   = union_params(unquote(params), extra)
        callback = &ExWechat.Http.parse_response(&1, __MODULE__, name, body, params)

        apply(ExWechat.Http, verb, [[url: url, body: body, params: params], callback])
      end
    end
  end

  defp define_helper_method do
    quote do
      defp union_params(params, added_params)
      defp union_params(nil, nil), do: []
      defp union_params(nil, added_params), do: added_params
      defp union_params(params, nil), do: params
      defp union_params(params, added_params) do
        params |> parse_params(__MODULE__) |> Keyword.merge(added_params)
      end
    end
  end
end
