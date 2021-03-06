
defmodule SlackClient do
    @behaviour ChatClientBehaviour

    require Logger

    def send_message(channel, message, slack) do
        Logger.info("sending message to #{inspect(message)} with channel #{inspect(channel)} slack")        
        if (message && respond_to_slack?()) do
            Slack.Sends.send_message(message, channel, slack)            
        end
    end

    def post_message(channel, message, attachments \\ %{}) do
        Logger.info("post message to #{inspect(message)} with channel #{inspect(channel)} slack")
        if (message && respond_to_slack?()) do
            Slack.Web.Chat.post_message(channel, message, attachments)
        end
    end

    def is_bot(user) do
        if user == nil do 
            true
        else
          case Slack.Web.Users.info(user) do
            %{"user" => %{"is_bot" => is_bot}} -> is_bot
            _ -> true
          end 
        end
    end

    def get_name_from_slack_id(slack_id) do
        case Slack.Web.Users.info(slack_id) do
            %{"user" => %{"name" => name}} -> name
            _ -> ""
        end
    end

    def get_avatar_url_from_slack_id(slack_id) do
        case Slack.Web.Users.info(slack_id) do
            %{"user" => %{"profile" => %{"image_original" => url}}} -> url
            _ -> ""
        end
    end

    defp respond_to_slack? do
        Application.get_env(:slack, :respond_to_slack)
    end
end