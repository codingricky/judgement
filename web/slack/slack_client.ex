defmodule SlackClient do
    def send_message(message, channel, slack) do
        if (Application.get_env(:slack, :respond_to_slack)) do
            Slack.Sends.send_message(message, channel, slack)            
        end
    end

    def post_message(channel, message, attachments) do
        if (Application.get_env(:slack, :respond_to_slack)) do
            Slack.Web.Chat.post_message(channel, message, attachments)
        end
    end
end