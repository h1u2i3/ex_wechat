defmodule Wechat.Token do
  @moduledoc """
    Wechat Token(access_token, jsapi_ticket, wxcard_ticket) fetcher.

    It contains a `Agent` to save tokens.
    A token only survive for 7190 seconds.
  """
  use GenServer

  @type token :: {token_key, token_value}

  @type token_key :: {api, token_type}
  @type api :: atom
  @type token_type :: :access_token | :jsapi_ticket | :wxcard_ticket

  @type token_value :: {token_value, timestamp}
  @type token_string :: binary
  @type timestamp :: non_neg_integer

  @type state :: map

  @type on_start :: {:ok, pid} | {:error, {:already_started, pid} | term}
  @type options :: [option]
  @type option ::
          {:debug, debug}
          | {:name, name}
          | {:timeout, timeout}
          | {:spawn_opt, Process.spawn_opt()}

  @type debug :: [:trace | :log | :statistics | {:log_to_file, Path.t()}]
  @type name :: atom | {:global, term} | {:via, module, term}

  @cache Wechat.Token.Cache

  # ================
  # Server
  # ================

  @doc """
  Start the Wechat.Token
  """
  @spec start_link(opts :: options) :: on_start
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Initialize the cache and the checker
  """
  @spec init(:ok) :: {:ok, state}
  def init(:ok) do
    # initialize the cache
    {:ok, cache} = Agent.start_link(&Map.new/0, name: @cache)
    # the loop checker, aim to abandon the token live long then 7190 seconds.
    {:ok, checker} = Task.start_link(fn -> token_checker(cache) end)
    # the waiting queue
    waiting = %{}
    # the fetching queue, prevent from repeat fetch request
    fetching = []

    {:ok, %{cache: cache, checker: checker, waiting: waiting, fetching: fetching}}
  end

  # ================
  # Callbacks
  # ================
  def handle_call({:get, token_key}, from, state) do
    %{waiting: waiting, fetching: fetching} = state

    token_value = get_cache(&Map.get(&1, token_key))
    is_fetching = token_key in fetching
    is_waiting = from in Map.get(waiting, token_key, [])

    cond do
      token_value ->
        {:reply, token_value |> elem(0), state}

      !token_value && is_fetching && is_waiting ->
        {:noreply, state, :infinity}

      !token_value && is_fetching && !is_waiting ->
        waiting = put_in_waiting(waiting, token_key, from)
        {:noreply, %{state | waiting: waiting}, :infinity}

      !token_value && !is_fetching ->
        waiting = put_in_waiting(waiting, token_key, from)
        fetching = [token_key | fetching]
        GenServer.cast(__MODULE__, {:fetch, token_key})
        {:noreply, %{state | waiting: waiting, fetching: fetching}, :infinity}

      true ->
        waiting = [from]
        fetching = []
        GenServer.cast(__MODULE__, {:fetch, token_key})
        {:noreply, %{state | waiting: waiting, fetching: fetching}}
    end
  end

  def handle_call({:refresh, token_key}, from, state) do
    %{waiting: waiting, fetching: fetching} = state

    waiting = put_in_waiting(waiting, token_key, from)
    fetching = [token_key | fetching]

    # delete the token from cache
    update_cache(&Map.delete(&1, token_key))

    # fetch the token from server
    GenServer.cast(__MODULE__, {:fetch, token_key})
    {:noreply, %{state | waiting: waiting, fetching: fetching}}
  end

  def handle_cast({:fetch, token_key}, state) do
    %{waiting: waiting, fetching: fetching} = state

    # get module and token_type
    {module, token_type} = token_key

    # call the module method to get the token
    method = "get_#{token_type}" |> String.to_atom()
    token_response = apply(module, method, [])
    token_string = parse_token_string(token_response, token_type)

    # send token to the pid in waiting queue
    Enum.map(Map.get(waiting, token_key, []), fn pid ->
      GenServer.reply(pid, token_string)
    end)

    # update the cache
    update_cache(&Map.put(&1, token_key, {token_string, current_timestamp()}))

    # change the state
    {:noreply,
     %{
       state
       | waiting: Map.delete(waiting, token_key),
         fetching: List.delete(fetching, token_key)
     }}
  end

  # ================
  # Clients
  # ================
  for token_type <- [:jsapi_ticket, :wxcard_ticket] do
    @doc """
    Get the #{token_type} from wechat server
    """
    def unquote(:"_#{token_type}")(module) do
      GenServer.call(__MODULE__, {:get, {module, unquote(token_type)}})
    end
  end

  @doc """
  Get the access_token from wechat server
  """
  def _access_token(module) do
    token_value = get_cache(&Map.get(&1, {module, :access_token}))

    cond do
      token_value ->
        elem(token_value, 0)

      true ->
        # can get token from other server
        token_module = Application.get_env(:ex_wechat, :token_module)
        token_response = apply(token_module || module, :get_access_token, [])

        if token_module do
          %{access_token: access_token, timestamp: timestamp} = token_response
          update_cache(&Map.put(&1, {module, :access_token}, {access_token, timestamp - 10}))
          access_token
        else
          token_string = parse_token_string(token_response, :access_token)
          update_cache(&Map.put(&1, {module, :access_token}, {token_string, current_timestamp()}))
          token_string
        end
    end
  end

  # ================
  # Server Private
  # ================

  # check with token, and remove the token that over 7190 seconds
  @spec token_checker(cache :: pid) :: any
  defp token_checker(cache) do
    # sleep for 1 second
    Process.sleep(1000)
    # get all the cache value from Wechat.Token.Cache
    tokens = get_cache(& &1)
    check_with_time(tokens)
    token_checker(cache)
  end

  # check with the token's timestamp
  @spec check_with_time(tokens :: map) :: :ok
  defp check_with_time(tokens) do
    Enum.map(tokens, &check_token(&1))
    :ok
  end

  @spec check_token(token :: token) :: :ok
  defp check_token(token) do
    {token_key, token_value} = token
    {_, timestamp} = token_value

    if current_timestamp() - timestamp >= 7190 do
      update_cache(fn cache ->
        # send the message to refresh the token
        Map.delete(cache, token_key)
      end)
    end

    :ok
  end

  @spec get_cache(fun :: function) :: any
  defp get_cache(fun) do
    Agent.get(@cache, fun)
  end

  @spec update_cache(fun :: function) :: :ok
  defp update_cache(fun) do
    Agent.update(@cache, fun)
  end

  @spec parse_token_string(token_response :: map, token_type :: token_type) :: binary | nil
  defp parse_token_string(token_response, token_type) do
    case token_type do
      :access_token -> token_response[token_type]
      _ -> token_response[:ticket]
    end
  end

  @spec current_timestamp() :: non_neg_integer
  defp current_timestamp() do
    System.os_time(:second)
  end

  @spec put_in_waiting(waiting :: map, token_key :: token_key, from :: pid) :: map
  defp put_in_waiting(waiting, token_key, from) do
    waiting
    |> Map.get_and_update(token_key, &{&1, [from | List.wrap(&1)]})
    |> elem(1)
  end
end
