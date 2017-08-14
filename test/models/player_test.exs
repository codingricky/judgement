defmodule Judgement.PlayerTest do
  use Judgement.ModelCase

  alias Judgement.Player

  @valid_attrs %{email: "some email", name: "some name"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end
