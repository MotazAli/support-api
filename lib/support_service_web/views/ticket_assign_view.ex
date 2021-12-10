defmodule SupportServiceWeb.TicketAssignView do

  use SupportServiceWeb, :view
  alias SupportServiceWeb.TicketAssignView

  def render("index.json", %{ticket_assigns: ticket_assigns}) do
    render_many(ticket_assigns, TicketAssignView, "ticket_assign.json")
  end

  def render("show.json", %{ticket_assign: ticket_assign}) do
    render_one(ticket_assign, TicketAssignView, "ticket_assign.json")
  end

  def render("ticket_assign.json", %{ticket_assign: ticket_assign})
  when ticket_assign != nil and ticket_assign.id != nil do
    %{
      id: ticket_assign.id,
      ticket_id: ticket_assign.ticket_id,
      ticket_status_type_id: ticket_assign.ticket_status_type_id,
      user_id: ticket_assign.user_id,
      inserted_at: ticket_assign.inserted_at,
      updated_at: ticket_assign.updated_at
    }
  end

  def render("ticket_assign.json", %{ticket_assign: _ticket_assign})  do
    %{}
  end

end
