defmodule Mix.Tasks.Wechat.User do
  use Mix.Tasks.Wechat, :base

  def run(_) do
    print_help_message
  end

  defp print_help_message do
    Mix.shell.info """
    # Wechat User functions:
    mix wechat.user           # Help message
    mix wechat.user.list      # Get user list
    mix wechat.user.info      # Get the infomation about user
    """
  end

  defmodule Info do
    use Mix.Tasks.Wechat, :http

    def run_http(args) do
      case args do
        []  ->
          Mix.shell.error "Please call with an openid. " <>
            "eg: mix wechat.user.info oN6zawh-nQLvAbeN11KkKCZZVbKM"
        [id | []] ->
          pp ExWechat.get_user_info(openid: id)
        _   ->
          pp Enum.map(args, fn(id)->
               ExWechat.get_user_info(openid: id)
             end)
      end
    end
  end

  defmodule List do
    use Mix.Tasks.Wechat, :http

    def run_http(_) do
      pp ExWechat.get_user_list
    end
  end
end
