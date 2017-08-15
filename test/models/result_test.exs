defmodule Judgement.ResultTest do
  use Judgement.ModelCase

  alias Judgement.Result

  @valid_attrs %{loser_id: 42, loser_points_after: 42, loser_points_before: 42, winner_id: 42, winner_points_after: 42, winner_points_before: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Result.changeset(%Result{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Result.changeset(%Result{}, @invalid_attrs)
    refute changeset.valid?
  end
end
