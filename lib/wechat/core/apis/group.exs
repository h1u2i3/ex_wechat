use Mix.Config

config :create_group,
  doc: """
  Create user group
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/groups/create",
  http: :post,
  params: [access_token: nil]

config :get_groups,
  doc: """
  Get groups
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/groups/get",
  http: :get,
  params: [access_token: nil]

config :update_group_member,
  doc: """
  Update group member
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/groups/members/update",
  http: :post,
  params: [access_token: nil]

config :batch_update_group_member,
  doc: """
  Batch update group member
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/groups/members/batchupdate",
  http: :post,
  params: [access_token: nil]

config :delete_group,
  doc: """
  Delete the users in group
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/groups/delete",
  http: :post,
  params: [access_token: nil]
