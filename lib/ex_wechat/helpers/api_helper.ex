defmodule ExWechat.Helpers.ApiHelper do
  @moduledoc """
    praser data from api description file.
  """
  @api_path Path.join(__DIR__, "../apis")


  @doc """
    Process for needed api definition data.
  """
  def process_api_definition_data(needed)

  def process_api_definition_data(nil) do
    process_api_definition_data(:all)
  end

  def process_api_definition_data(:all) do
    all_api_definition_data
  end

  def process_api_definition_data(needed) do
    all_api_definition_data
    |> Keyword.take(needed ++ [:access_token])
  end

  @doc """
    Get all the definition files, include that user defines.
  """
  def all_definition_files(module) do
    module
    |> apply(:api_definition_files, [])
    |> get_all_definition_files
  end

  #  Grabs all the definition files.
  defp get_all_definition_files(user_define_path)

  defp get_all_definition_files(nil) do
    all_files_in_folder(@api_path)
  end

  defp get_all_definition_files(user_define_path) do
    all_files_in_folder(@api_path) ++ all_files_in_folder(user_define_path)
  end

  defp all_files_in_folder(path) do
    Path.wildcard(path <> "/*")
  end


  # Get all the data of all the api definition file
  defp all_api_definition_data do
    ExWechat.Api
    |> all_definition_files
    |> get_all_definition_data
  end


  # Read the data from every file.
  defp get_all_definition_data(files, result \\ [])

  defp get_all_definition_data([], result) do
    result
  end

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
    path
    |> Mix.Config.read!
  end
end
