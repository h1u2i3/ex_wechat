defmodule ExWechat.Helpers.TransformerTest do
  use ExUnit.Case

  import ExWechat.Helpers.Transformer

  def keyword_example do
    [
      name: "xiaohui",
      school: [
        class: "29",
        info: [
          students: 89
        ],
        articles: [
          [
            book: "first",
            year: "2009"
          ],
          [
            book: "second",
            year: "2009"
          ],
          [
            book: "thread",
            year: "2009"
          ]
        ]
      ]
    ]
  end

  def map_result do
    %{
      name: "xiaohui",
      school: %{
        class: "29",
        info: %{
          students: 89
        },
        articles: [
         %{
            book: "first",
            year: "2009"
          },
         %{
            book: "second",
            year: "2009"
          },
         %{
            book: "thread",
            year: "2009"
          }
        ]
      }
    }
  end

  test "should transform from keyword to map" do
    result = keyword_to_map(keyword_example())

    assert result == map_result()
  end
end
