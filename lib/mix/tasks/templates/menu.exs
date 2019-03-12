use Mix.Config

config :data,
  menu: [
    buttons: [
      [name: "百度", sub_button: [], type: "view", url: "http://www.baidu.com"],
      [
        name: "互动",
        sub_button: [
          [type: "scancode_waitmsg", name: "扫码带提示", key: "rselfmenu_0_0", sub_button: []],
          [type: "scancode_push", name: "扫码推事件", key: "rselfmenu_0_1", sub_button: []]
        ]
      ]
    ],
    matchrule: [
      group_id: "2",
      sex: "1",
      country: "中国",
      province: "广东",
      city: "广州",
      client_platform_type: "2",
      language: "zh_CN"
    ]
  ]
