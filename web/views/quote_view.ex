defmodule Judgement.QuoteView do
    def render("index.json", %{quote: message}) do
        %{"quote" => message}
    end
end  