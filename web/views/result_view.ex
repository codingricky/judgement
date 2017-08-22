defmodule Judgement.ResultView do
    use Judgement.Web, :view
    use Phoenix.Controller

    alias Judgement.Player
    alias Judgement.Result
    
    def player_list(conn) do
        conn.assigns.player_list
    end

    def show_flash(conn) do
        get_flash(conn) |> flash_msg
    end
    
    def flash_msg(_) do 
    end

    def flash_msg(%{"info" => msg}) do
    ~E"<div class='alert alert-info'><%= msg %></div>"
    end

    def flash_msg(%{"error" => msg}) do
    ~E"<div class='alert alert-danger'><%= msg %></div>"
    end

    def streak(player) do
        Player.find_by_id(player.player_id)
            |> Result.last_n(10)
            |> Enum.map &(convert_to_char(&1, player)) 
    end

    def convert_to_char(result, player) do
        if result.winner.id == player.player_id do
            "W" 
        else
            "L"
        end
  end
end  