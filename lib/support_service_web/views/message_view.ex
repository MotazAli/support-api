defmodule SupportServiceWeb.MessageView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.MessageView

  def render("index.json", %{messages: messages}) do
    render_many(messages, MessageView, "message.json")
  end

  def render("show.json", %{message: message}) do
    render_one(message, MessageView, "message.json")
  end

  def render("message.json", %{message: message})
  when message != nil and message.id != nil do
    %{
      id: message.id,
      text: message.text,
      is_client: message.is_client,
      message_type_id: message.message_type_id,
      inserted_at: message.inserted_at,
      updated_at: message.updated_at
    }
  end

  def render("message.json", %{message: _message})  do
    %{}
  end


end
