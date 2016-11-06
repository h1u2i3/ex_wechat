defmodule ExWechat.Base do
  @moduledoc """
    Make module can get the config data.

        use ExWechat.Base

    then, you can get the config data in your module.
  """

  defmacro __using__(_opts) do
    for {key, value} <- Application.get_env(:ex_wechat, ExWechat) do
      quote do
        def unquote(key)() do
          unquote(value)
        end
      end
    end
  end
end
