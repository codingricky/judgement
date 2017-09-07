
defmodule MockSlackClient do
    @behaviour ChatClientBehaviour
    
    require Logger

    def send_message(_message, _channel, _slack) do
    end

    def post_message(_channel, _message, _attachments \\ %{}) do
    end

    def is_bot(_user) do
        false
    end

    def get_name_from_slack_id(slack_id) do
        ""
    end

    def get_avatar_url_from_slack_id(slack_id) do
        ""
    end
end