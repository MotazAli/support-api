defmodule SupportServiceWeb.TicketView do

  use SupportServiceWeb, :view
  alias SupportServiceWeb.{TicketView,MessageView}

  def render("index.json", %{tickets: tickets}) do
    render_many(tickets, TicketView, "ticket.json")
  end

  def render("show.json", %{ticket: ticket}) do
    render_one(ticket, TicketView, "ticket.json")
  end

  def render("ticket.json", %{ticket: ticket})
  when ticket != nil and ticket.id != nil do
    %{
      id: ticket.id,
      description: ticket.description,
      ticket_type: ticket.ticket_type,
      ticket_status_type_id: ticket.ticket_status_type_id,
      ticket_status_type: ticket.ticket_status_type,
      client: ticket.client,
      ticket_assign: ticket.ticket_assign,
      messages: if ticket.messages != nil do render_many(ticket.messages, MessageView, "message.json") else [] end ,
      websocket: if ticket.websocket != nil do ticket.websocket else "" end,
      topic: if ticket.topic != nil do ticket.topic else "" end,
      receive_message: if ticket.receive_message != nil do ticket.receive_message else "" end,
      receive_status: if ticket.receive_status != nil do ticket.receive_status else "" end,
      push_message: if ticket.push_message != nil do ticket.push_message else "" end,
      push_status: if ticket.push_status != nil do ticket.push_status else "" end,
      inserted_at: ticket.inserted_at,
      updated_at: ticket.updated_at
    }
  end

  def render("ticket.json", %{ticket: _ticket})  do
    %{}
  end

end
