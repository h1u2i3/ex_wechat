defmodule ExWechat.Base do

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
