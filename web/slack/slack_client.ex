
defmodule SlackClient do
    require Logger

    def send_message(message, channel, slack) do
        Logger.info("sending message to #{inspect(message)} slack")
        if (message && respond_to_slack?()) do
            Slack.Sends.send_message(message, channel, slack)            
        end
    end

    def post_message(channel, message, attachments) do
        Logger.info("post message to #{inspect(message)} slack")
        if (message && respond_to_slack?()) do
            Slack.Web.Chat.post_message(channel, message, attachments)
        end
    end

    defp respond_to_slack? do
        Application.get_env(:slack, :respond_to_slack)
    end
end