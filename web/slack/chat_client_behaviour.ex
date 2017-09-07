
defmodule ChatClientBehaviour do

    @callback send_message(message :: any, channel :: any, slack :: any) :: any

    @callback post_message(channel :: any, message :: any, attachments :: any) :: any

    @callback is_bot(user :: any) :: boolean()
end