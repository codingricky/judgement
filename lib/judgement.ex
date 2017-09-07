defmodule Judgement do
  use Application
  import Supervisor.Spec
  
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = default_children() ++ slack_bot_child()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Judgement.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp default_children do    
    [supervisor(Judgement.Repo, []),
    supervisor(Judgement.Endpoint, [])]
  end

  defp slack_bot_child do
    if String.length(System.get_env("SLACK_API_TOKEN")) > 0, do: [worker(Slack.Bot, [SlackRtm, [], System.get_env("SLACK_API_TOKEN")])], else: []
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Judgement.Endpoint.config_change(changed, removed)
    :ok
  end
end
