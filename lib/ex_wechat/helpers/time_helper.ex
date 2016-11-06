defmodule ExWechat.Helpers.TimeHelper do
  @moduledoc """
    Helper methods for time calucate.
  """

  @doc """
    get unix timestamp
  """
  def current_unix_time do
    :os.system_time(:second)
  end

  @doc """
    tranfrom the erl datetime tuple to unix timestamp
  """
  def erl_datetime_to_unix_time(datetime) do
    :calendar.datetime_to_gregorian_seconds(datetime) - 62167219200
  end
end
