require IEx

defmodule Judgement.Plugs.RequireLogin do
    import Plug.Conn
  
    def init(opts), do: opts
  
    def call(conn, _) do
        if get_session(conn, :current_user) do
          conn
        else
          conn |> redirect_to_login
        end
    end

    defp redirect_to_login(conn) do
        conn |> Phoenix.Controller.redirect(to: "/users/sign_in") |> halt
    end
  end