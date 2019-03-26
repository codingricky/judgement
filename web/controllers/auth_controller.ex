require IEx
defmodule Judgement.AuthController do
    use Judgement.Web, :controller
    
  @doc """
  This action is reached via `/auth` and redirects to the Google OAuth2 provider.
  """
  def index(conn, _params) do
    redirect conn, external: Google.authorize_url!(
      scope: "https://www.googleapis.com/auth/userinfo.email"
    )
  end
  
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
  
    @doc """
    This action is reached via `/auth/:provider/callback` is the the callback URL that
    the OAuth2 provider will redirect the user back to with a `code` that will
    be used to request an access token. The access token will then be used to
    access protected resources on behalf of the user.
    """
  def callback(conn, %{"code" => code}) do
      # Exchange an auth code for an access token
      client = Google.get_token!(code: code)

      # Request the user's data with the access token
      scope = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
      %{body: user} = OAuth2.Client.get!(client, scope)

      current_user = %{
        name: user["name"],
        avatar: String.replace_suffix(user["picture"], "?sz=50", "?sz=400")
      }
      supported_domain = System.get_env("SUPPORTED_DOMAIN")
      if user["hd"] != supported_domain do
        conn
        |> send_resp(401, "Not allowed")
        |> halt    
      else
        conn
        |> put_session(:current_user, user)
        |> put_session(:access_token, client.token.access_token)
        |> redirect(to: "/")
      end
    end
  end