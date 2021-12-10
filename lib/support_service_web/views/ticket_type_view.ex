defmodule SupportServiceWeb.TicketTypeView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.TicketTypeView

  def render("index.json", %{ticket_types: ticket_types}) do
    render_many(ticket_types, TicketTypeView, "ticket_type.json")
  end

  def render("show.json", %{ticket_type: ticket_type}) do
    render_one(ticket_type, TicketTypeView, "ticket_type.json")
  end

  def render("ticket_type.json", %{ticket_type: ticket_type})
  when ticket_type != nil and ticket_type.id != nil do
    %{
      id: ticket_type.id,
      type: ticket_type.type,
      arabic_type: ticket_type.arabic_type,
      inserted_at: ticket_type.inserted_at,
      updated_at: ticket_type.updated_at
    }
  end

  def render("ticket_type.json", %{ticket_type: _ticket_type})  do
    %{}
  end


end
