defmodule Judgement.PlayerController do
    use Judgement.Web, :controller
    
    alias Judgement.Player

    def new(conn, _params) do
        changeset = Player.changeset(%Player{})
        render conn, "new.html", changeset: changeset
    end
  end
  