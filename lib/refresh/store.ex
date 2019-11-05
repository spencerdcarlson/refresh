defmodule Store do
  use GenServer

  @table :refresh
  @pid Refresh.Store

  @impl true
  def init(_options) do
    {:ok, :ets.new(@table, [:set, :protected])}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put(opts, :name, @pid))
  end

  defp pid, do: Process.whereis(@pid)
  defp normalize_key(:module, key), do: "#{key}__module"
  defp normalize_key(:expire, key), do: "#{key}__expires_at"
  defp normalize_key(:value, key), do: "#{key}__value"

  # Public API
  def attach(key, module),
    do: GenServer.cast(pid(), {:insert, normalize_key(:module, key), module})

  def module(key), do: GenServer.call(pid(), {:get, normalize_key(:module, key)})

  def expires_at(key, expires_at),
    do: GenServer.cast(pid(), {:insert, normalize_key(:expire, key), expires_at})

  def expired?(key),
    do: Time.utc_now() > GenServer.call(pid(), {:get, normalize_key(:expire, key)})

  def put(key, value), do: GenServer.cast(pid(), {:insert, normalize_key(:value, key), value})
  def get(key), do: GenServer.call(pid(), {:get, normalize_key(:value, key)})

  def delete(key), do: GenServer.cast(pid(), {:delete, key})

  @impl true
  def handle_call({:get, key}, _from, table) do
    case :ets.lookup(table, key) do
      [{^key, value}] -> {:reply, value, table}
      [] -> {:reply, nil, table}
    end
  end

  @impl true
  def handle_cast({:insert, key, value}, table) do
    case :ets.insert(table, {key, value}) do
      true -> {:noreply, table}
      _ -> {:stop, :ets_insert_error, table}
    end
  end

  @impl true
  def handle_cast({:delete, key}, table) do
    case :ets.delete(table, key) do
      true -> {:noreply, table}
      _ -> {:stop, :ets_delete_error, table}
    end
  end
end
