defmodule Wechat.Helpers.XmlRender do
  @moduledoc """
  Render elixir data to xml.
  """
  @template_folder Path.join(__DIR__, "../templates")

  # use eex magic to generate template method
  require EEx
  for type <- ~w/text image voice video music news/a do
    with path <- (@template_folder <> "/#{type}.eex"),
      do: EEx.function_from_file :def, type, path, [:assigns]
  end

  @doc """
  Render `.eex` file to xml base on assigned value.
  """
  def render_xml(assigns) when is_map(assigns) do
    render_xml Map.to_list(assigns)
  end

  def render_xml(assigns) when is_list(assigns) do
    apply(__MODULE__, assigns[:msgtype] |> String.to_atom, [assigns])
  end

  @doc """
  Render file to xml data.
  """
  def render_xml(file, assigns) do
    EEx.eval_file file, assigns: assigns
  end
end
