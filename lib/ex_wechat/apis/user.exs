use Mix.Config

config :create_user_tag,
  doc: """
    create user tag
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/create",
  http: :post,
  params: [access_token: nil]

config :get_user_tag,
  doc: """
    Get user tags
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/get",
  http: :get,
  params: [access_token: nil]

config :update_user_tag,
  doc: """
    update user tag
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/update",
  http: :post,
  params: [access_token: nil]

config :delete_user_tag,
  doc: """
    delete user tag
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/delete",
  http: :post,
  params: [access_token: nil]

config :get_users_in_tag,
  doc: """
    Get uses in tag
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/user/tag/get",
  http: :post,
  params: [access_token: nil]

config :tag_at_users,
  doc: """
    tag at user
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/members/batchtagging",
  http: :post,
  params: [access_token: nil]

config :untag_at_users,
  doc: """
    untag user
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/members/batchuntagging",
  http: :post,
  params: [access_token: nil]

config :get_tags_on_user,
  doc: """
    Get user's tag
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/getidlist",
  http: :post,
  params: [access_token: nil]

config :update_user_remark,
  doc: """
    update user remark
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/user/info/updateremark",
  http: :post,
  params: [access_token: nil]

config :get_user_info,
  doc: """
    Get user info, added_params(openid)
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/user/info",
  http: :get,
  params: [access_token: nil, lang: "zh_CN"]

config :get_users_info,
  doc: """
    Get users info
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/user/info/batchget",
  http: :post,
  params: [access_token: nil]

config :get_user_list,
  doc: """
    Get user list
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/user/get",
  http: :get,
  params: [access_token: nil]

config :get_blacklist,
  doc: """
    Get users in blacklists
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/members/getblacklist",
  http: :post,
  params: [access_token: nil]

config :put_blacklist,
  doc: """
    Put users in blacklist
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/members/batchblacklist",
  http: :post,
  params: [access_token: nil]

config :cancel_blacklist,
  doc: """
    Cancel user in blacklist
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/tags/members/batchunblacklist",
  http: :post,
  params: [access_token: nil]
