Mix.shell(Mix.Shell.Process)

ExUnit.start()

Enum.map Path.wildcard(Path.join(__DIR__, "ex_wechat/test_helper/*")),
          fn(file) -> Code.load_file(file) end
