defmodule Judgement.ResultView do
    use Judgement.Web, :view
    use Phoenix.Controller
    
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
end  