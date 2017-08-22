defmodule Judgement.Router do
  use Judgement.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # no login
  scope "/", Judgement do
    pipe_through :browser

    get "/users/sign_in", SignInController, :index    
  end

  # logged in
  scope "/", Judgement do
    pipe_through [:browser, Judgement.Plugs.RequireLogin]

    get "/", PageController, :index
    get "/undo", PageController, :undo    
    resources "/player", PlayerController
    resources "/result", ResultController
    get "/full_rankings", ResultController, :full_rankings
  end

  scope "/auth", Judgement do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end

  # Other scopes may use custom stacks.
  # scope "/api", Judgement do
  #   pipe_through :api
  # end
end
