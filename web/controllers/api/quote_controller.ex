require IEx

defmodule Judgement.QuoteController do
    use Judgement.Web, :controller

    alias Judgement.Player
    
    def index(conn, _params) do
        message = Player.what_would_tony_say()
        render conn, "index.json", quote: message        
    end
end