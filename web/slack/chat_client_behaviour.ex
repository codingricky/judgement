
defmodule ChatClientBehaviour do

    @callback send_message(message :: any, channel :: any, slack :: any) :: any

    @callback post_message(channel :: any, message :: any, attachments :: any) :: any

    @callback is_bot(user :: any) :: boolean()

    @callback get_name_from_slack_id(slack_id :: string()) :: string()

    @callback get_avatar_url_from_slack_id(slack_id :: string()) :: string()
end