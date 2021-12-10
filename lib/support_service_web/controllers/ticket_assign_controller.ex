defmodule SupportServiceWeb.TicketAssignController do
  use SupportServiceWeb, :controller
  alias SupportService.Serve
  alias SupportService.Serve.{TicketAssign}


  action_fallback SupportServiceWeb.FallbackController
  plug :authenticate_api_user when action in [:index,:create,:show,:update,:delete]

  def index(conn,_param) do
    tickets = Serve.list_tickets_assigns()
    render(conn, "index.json", ticket_assign: tickets)
  end




  def show(conn, %{"id" => id} = _param) do
    try do
      ticket_assign = Serve.get_ticket_assign!(id)
      render(conn,"show.json", ticket_assign: ticket_assign )
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", ticket_assign: %TicketAssign{})
    end
  end

end
