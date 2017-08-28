defmodule Judgement.ApiResultView do
    use Judgement.Web, :view

    def render("index.json", %{message: message}) do
        %{"message" => message}
    end
end  