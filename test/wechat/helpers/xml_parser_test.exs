defmodule Wechat.Helpers.XmlParserTest do
  use ExUnit.Case, async: true

  @map %{
    name: "h1u2i3",
    age: "10",
    book: %{
      title: "book",
      author: "some"
    }
  }

  @value """
  <xml>
    <name>h1u2i3</name>
    <age>10</age>
    <book>
      <title>book</title>
      <author>some</author>
    </book>
  </xml>
  """

  test "should get the right data in elixir map" do
    assert @map == Wechat.Helpers.XmlParser.parse_xml @value
  end
end
