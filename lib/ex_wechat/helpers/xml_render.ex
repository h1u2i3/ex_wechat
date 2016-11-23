defmodule ExWechat.Helpers.XmlRender do
  @moduledoc """
  Render elixir data to xml.
  """
  @template_folder Path.join(__DIR__, "../templates")

  require EEx
  EEx.function_from_file :def, :text,  @template_folder <> "/text.eex",  [:assigns]
  EEx.function_from_file :def, :image, @template_folder <> "/image.eex", [:assigns]
  EEx.function_from_file :def, :voice, @template_folder <> "/voice.eex", [:assigns]
  EEx.function_from_file :def, :video, @template_folder <> "/video.eex", [:assigns]
  EEx.function_from_file :def, :music, @template_folder <> "/music.eex", [:assigns]
  EEx.function_from_file :def, :news,  @template_folder <> "/news.eex",  [:assigns]

  @doc """
  Render `.eex` file to xml base on assigned value.
  """
  def render_xml(assigns)

  def render_xml(%{} = assigns) do
    render_xml(Enum.map(assigns, fn ({key, value}) ->
                 {key, value}
               end))
  end

  def render_xml(assigns) do
    apply(__MODULE__, assigns[:msgtype] |> String.to_atom, [assigns])
  end

  @doc """
  Render file to xml data.
  """
  def render_xml(file, assigns) do
    EEx.eval_file file, assigns: assigns
  end
end
