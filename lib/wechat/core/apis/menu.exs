use Mix.Config

config :get_menu,
  doc: """
    Get the menu that are using.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/menu/get",
  http: :get,
  params: [access_token: nil]

config :create_menu,
  doc: """
    Create the menu
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/menu/create",
  http: :post,
  params: [access_token: nil]

config :delete_menu,
  doc: """
    Delete the menu
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/menu/delete",
  http: :get,
  params: [access_token: nil]

config :create_special_menu,
  doc: """
    Special menu create
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/menu/addconditional",
  http: :post,
  params: [access_token: nil]

config :delete_special_menu,
  doc: """
    Delete special menu
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/menu/delconditional",
  http: :post,
  params: [access_token: nil]

config :get_menu_conf,
  doc: """
    Get all the menu config
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/get_current_selfmenu_info",
  http: :get,
  params: [access_token: nil]
