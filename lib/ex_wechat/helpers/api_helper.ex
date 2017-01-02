defmodule ExWechat.Helpers.ApiHelper do
  @moduledoc """
    praser data from api description file.
  """
  @api_path Path.join(__DIR__, "../core/apis")

  for file <- Path.wildcard("../core/apis/*") do
    @external_resource file
  end

  @doc """
    Process for needed api definition data.
  """
  def process_api_definition_data(nil), do: process_api_definition_data(:all)
  def process_api_definition_data(:all), do: all_api_definition_data()
  def process_api_definition_data(needed) do
    all_api_definition_data() |> Keyword.take([:access_token | needed])
  end

  # Get all the data of all the api definition file
  defp all_api_definition_data do
    @api_path
    |> all_files_in_folder
    |> get_all_definition_data
  end

  # Grab all the file in floder
  defp all_files_in_folder(path) do
    Path.wildcard(path <> "/*")
  end

  # Read the data from every file.
  defp get_all_definition_data(files, result \\ [])
  defp get_all_definition_data([], result), do: result
  defp get_all_definition_data([file | tail], result) do
    key = get_key_from_path(file)
    data = Keyword.put(result, key,
              Keyword.get(result, key, []) ++ (file |> api_definition_data))
    get_all_definition_data(tail, data)
  end

  defp get_key_from_path(path) do
    path
    |> Path.basename(".exs")
    |> String.to_atom
  end

  defp api_definition_data(path) do
    path |> Mix.Config.read!
  end
end
