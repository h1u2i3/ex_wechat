use Mix.Config

config :upload_media,
  doc: """
    upload media, needed_params(type)
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/media/upload",
  http: :post,
  params: [access_token: nil]

config :get_media,
  doc: """
    get media, added_params(media_id)
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/media/get",
  http: :get,
  params: [access_token: nil]

config :add_permanent_news,
  doc: """
    add forever news
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/add_news",
  http: :post,
  params: [access_token: nil]

config :add_permanent_image,
  doc: """
    add permanent image
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/media/uploadimg",
  http: :post,
  params: [access_token: nil]

config :add_other_permanent,
  doc: """
    add other permanent image
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/add_material",
  http: :post,
  params: [access_token: nil]

config :get_permanent,
  doc: """
    get permanent resource
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/get_material",
  http: :post,
  params: [access_token: nil]

config :delete_permanent,
  doc: """
    delete permanent resource
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/del_material",
  http: :post,
  params: [access_token: nil]

config :update_permanent_news,
  doc: """
    update permanent news
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/update_news",
  http: :post,
  params: [access_token: nil]

config :get_permanent_resources_count,
  doc: """
    get permanent resources count
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/get_materialcount",
  http: :get,
  params: [access_token: nil]

config :get_media_list,
  doc: """
    get media list
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/material/batchget_material",
  http: :post,
  params: [access_token: nil]
