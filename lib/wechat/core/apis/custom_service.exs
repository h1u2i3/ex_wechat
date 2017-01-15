use Mix.Config

config :add_kf_account,
  doc: """
    Add the kf_account
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/customservice/kfaccount/add",
  http: :post,
  params: [access_token: nil]

config :update_kf_account,
  doc: """
    Edit the kf_account
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/customservice/kfaccount/update",
  http: :post,
  params: [access_token: nil]

config :delete_kf_account,
  doc: """
    Delete the kf_account
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/customservice/kfaccount/del",
  http: :post,
  params: [access_token: nil]

config :update_kf_account_avatar,
  doc: """
    Change the avatar of kf_account, added_params(kf_account)
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/customservice/kfaccount/uploadheadimg",
  http: :post,
  params: [access_token: nil]

config :get_all_kf_account,
  doc: """
    Get all the kf_account
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/customservice/getkflist",
  http: :get,
  params: [access_token: nil]
