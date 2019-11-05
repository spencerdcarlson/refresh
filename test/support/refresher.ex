defmodule Refresher do
  @behaviour Refresh

  @impl Refresh
  def set(_id) do
    {:ok, [value: "my-aws-secret", expires_at: 3_600]}
  end
end
