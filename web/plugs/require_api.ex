require IEx

defmodule Judgement.Plugs.RequireApi do
    import Plug.Conn
    
    def init(default), do: default
  
    def call(conn, _) do        
        case get_req_header(conn, "authorization") do
            [header | _tail] -> handle_header(conn, header)
            _ -> send_unauthorized(conn)
        end
    end

    defp handle_header(conn, header) do
        bearer = String.trim(String.replace(header, "Bearer", ""))
        case Phoenix.Token.verify(Judgement.Endpoint, get_secret_key, bearer, max_age: 9999999999999) do
            {:ok, id} -> conn
            {:error, _} -> send_unauthorized(conn)
        end
    end

    def sign() do 
        Phoenix.Token.sign(Judgement.Endpoint, get_secret_key, 1)
    end

    def verify(token) do
        Phoenix.Token.verify(Judgement.Endpoint, get_secret_key, token, max_age: 9999999999999)        
    end

    defp send_unauthorized(conn) do
        conn
        |> send_resp(401, "Not allowed")
        |> halt    
    end

    defp get_secret_key do
        Application.get_env(:judgement, :api_secret)
    end
  end
  