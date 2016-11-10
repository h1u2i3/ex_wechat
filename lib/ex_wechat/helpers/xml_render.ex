defmodule ExWechat.Helpers.XmlRender do
  @moduledoc """
    Render elixir data to xml.
  """

  @doc """
    Render `.eex` file to xml base on assigned value.
  """
  def render_xml(file, assigns)
  def render_xml(file, %{} = assigns), do: render_xml(file, Enum.map(assigns, fn ({key, value}) -> {key, value} end))
  def render_xml(file, []  = assigns), do: EEx.eval_file Path.join([__DIR__, "templates", file]), assigns: assigns

end
