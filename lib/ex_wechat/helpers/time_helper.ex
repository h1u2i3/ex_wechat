defmodule ExWechat.Helpers.TimeHelper do
  @moduledoc """
  Helper methods for time calucate.
  """

  @doc """
  Get unix timestamp
  """
  def current_unix_time do
    DateTime.to_unix(DateTime.utc_now)
  end

  @doc """
  Transform the erl datetime tuple to unix timestamp
  """
  def erl_datetime_to_unix_time(datetime) do
    :calendar.datetime_to_gregorian_seconds(datetime) - 62167219200
  end
end
