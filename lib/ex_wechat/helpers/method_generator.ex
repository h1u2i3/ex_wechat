defmodule ExWechat.Helpers.MethodGenerator do
  @moduledoc """
    Generate AST method data base on api definition data.
  """

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
      define_helper_method()

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
      def unquote(name)() do
        unquote(name)(fn _ -> nil end, [])
      end
      def unquote(name)(callback) when is_function(callback) do
        unquote(name)(callback, [])
      end
      def unquote(name)(extra) when is_list(extra) do
        unquote(name)(fn _ -> nil end, extra)
      end
      def unquote(name)(callback, extra)
            when is_function(callback) and is_list(extra) do
        name  = unquote(name)
        verb  = unquote(verb)
        url   = unquote(url)
        params   = union_params(unquote(params), extra)

        wechat_case_fun =
          Application.get_env(:ex_wechat, :wechat_case)
        http_case_fun =
          Application.get_env(:ex_wechat, :http_case)
        default_callback =
          &ExWechat.Http.parse_response(&1, __MODULE__, name, nil, params)

        cond do
          is_function(wechat_case_fun) ->
            wechat_case_fun.()
          true ->
            callback =
              cond do
                is_function(http_case_fun) -> http_case_fun
                callback.(true) == nil -> default_callback
                true -> callback
              end
            opts = [url: url, params: params]
            apply(ExWechat.Http, verb, [opts, callback])
        end
      after
        delete_case_env()
      end
    end
  end

  defp gen_post_request_method(verb, name, doc, opts) do
    [url: url, params: params] = opts

    quote do
      @doc unquote(doc)
      def unquote(name)(body) do
        unquote(name)(body, fn _ -> nil end, [])
      end
      def unquote(name)(body, callback) when is_function(callback) do
        unquote(name)(body, callback, [])
      end
      def unquote(name)(body, extra) when is_list(extra) do
        unquote(name)(body, fn _ -> nil end, extra)
      end
      def unquote(name)(body, callback, extra)
            when is_function(callback) and is_list(extra) do
        name  = unquote(name)
        verb  = unquote(verb)
        url   = unquote(url)
        params   = union_params(unquote(params), extra)

        wechat_case_fun =
          Application.get_env(:ex_wechat, :wechat_case)
        http_case_fun =
          Application.get_env(:ex_wechat, :http_case)
        default_callback =
          &ExWechat.Http.parse_response(&1, __MODULE__, name, body, params)

        cond do
          is_function(wechat_case_fun) ->
            wechat_case_fun.()
          true ->
            callback =
              cond do
                is_function(http_case_fun) -> http_case_fun
                callback.(true) == nil -> default_callback
                true -> callback
              end
            opts = [url: url, body: body, params: params]
            apply(ExWechat.Http, verb, [opts, callback])
        end
      after
        delete_case_env()
      end
    end
  end

  defp define_helper_method do
    quote do
      defp union_params(params, added_params) do
        params |> parse_params(__MODULE__) |> Keyword.merge(added_params)
      end

      defp delete_case_env do
        Application.delete_env(:ex_wechat, :wechat_case)
        Application.delete_env(:ex_wechat, :wechat_case)
      end
    end
  end
end
