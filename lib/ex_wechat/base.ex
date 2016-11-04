defmodule ExWechat.Base do
  for {key, value} <- Application.get_env(:ex_wechat, ExWechat) do
    def unquote(key)() do
      unquote(value)
    end
  end
end
