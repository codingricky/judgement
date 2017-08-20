defmodule Judgement.SignInController do
    use Judgement.Web, :controller
  
    def index(conn, _params) do
      render conn, "index.html"
    end
end