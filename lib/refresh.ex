defmodule Refresh do
  @moduledoc """
    Stores a value, auto refreshes if it is expired so that a good value is always retrieved
  """
  @callback set(atom()) :: {:ok, any()} | {:error, any()}

  #  @callback after_set(atom()) :: {:ok, any()} | {:error, any()}
  #  @optional_callbacks [after_set: 1]
  #  function_exported?(module, :after_set, 1) |> IO.inspect(lable: "function_exported") # check if impl before invoking

  require Logger

  defmacro __using__(_) do
    quote do
      @behaviour Refresh
    end
  end

  @doc """
  Registers a module as a delegate under a unique id.
  At a minimum, the specified module must implement
  the following callbacks:
    * Refresh.set/1

  Returns `:ok | :error`

  """
  @spec attach(atom(), module()) :: :ok | :error
  def attach(id, module), do: Store.attach(id, module)

  @spec get(atom()) :: any()
  def get(id) do
    Logger.metadata(id: id)

    if Store.expired?(id) do
      Logger.debug("value is expired")
      refresh(id)
      Store.get(id)
    else
      Logger.debug("value is not expired")
      Store.get(id)
    end
  end

  defp refresh(id) do
    with module when not is_nil(module) <- Store.module(id),
         {:ok, [value: value, expires_at: seconds]} <- apply(module, :set, [id]) do
      Store.expires_at(id, calc(seconds))
      Store.put(id, value)
    else
      nil -> Logger.error("module is nil")
    end
  end

  defp calc(seconds),
    do:
      Time.utc_now()
      |> Time.add(seconds)
end
