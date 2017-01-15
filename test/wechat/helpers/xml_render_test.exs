defmodule Wechat.Helpers.XmlRenderTest do
  use ExUnit.Case, async: true

  import Wechat.TestHelper.AssertHelper

  @map %{
    name: "h1u2i3",
    age: "10",
    book: %{
      title: "book",
      author: "some"
    }
  }

  @template """
  <xml>
    <name><%= @name %></name>
    <age><%= @age %></age>
    <book>
      <title><%= @book.title %></title>
      <author><%= @book.author %></author>
    </book>
  </xml>
  """

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

  setup do
    File.write!("/tmp/xml_render_test", @template)
  end

  test "should render right xml data" do
    assert_equal_string @value,
      Wechat.Helpers.XmlRender.render_xml("/tmp/xml_render_test", @map)
  end
end
