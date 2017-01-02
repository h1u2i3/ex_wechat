defmodule Mix.Tasks.Wechat.User do
  @moduledoc false
  use Mix.Tasks.Wechat, :base

  def run(_) do
    print_help_message
  end

  defp print_help_message do
    Mix.shell.info """
    # Wechat User functions:

    mix wechat.user           Help message
    mix wechat.user.list      Get user list
      --api ExWechat            use --api to use the specific Api (muti account), default is ExWechat
    mix wechat.user.info      Get the infomation about user
      --api ExWechat            use --api to use the specific Api (muti account), default is ExWechat
    """
  end

  defmodule Info do
    @moduledoc false
    use Mix.Tasks.Wechat, :http

    def run_http(args) do
      options = parse_args(args)
      api = options[:api] || "ExWechat"
      module = api |> module_get
      options = Keyword.delete(options, :api)

      case options do
        []  ->
          Mix.shell.error "Please call with an openid. " <>
            "eg: mix wechat.user.info --api Manager oN6zawh-nQLvAbeN11KkKCZZVbKM"
        [id | []] ->
          pp apply(module, :get_user_info, [openid: id])
        _   ->
          pp Enum.map(args, fn(id)->
               apply(module, :get_user_info, [openid: id])
             end)
      end
    end
  end

  defmodule List do
    @moduledoc false
    use Mix.Tasks.Wechat, :http

    def run_http(args) do
      options = parse_args(args)
      api = options[:api] || "ExWechat"
      module = api |> module_get

      pp apply(module, :get_user_list, [])
    end
  end
end
