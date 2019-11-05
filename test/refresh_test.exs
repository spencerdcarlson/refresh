defmodule RefreshTest do
  use ExUnit.Case

  doctest Refresh

  alias Refresher

  test "greets the world" do
    assert :ok === Refresh.attach(:aws_token, Refresher)
    assert "my-aws-secret" === Refresh.get(:aws_token)
    assert "my-aws-secret" === Refresh.get(:aws_token)
  end
end
