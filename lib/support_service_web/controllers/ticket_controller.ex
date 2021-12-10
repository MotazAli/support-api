defmodule SupportServiceWeb.TicketController do
  use SupportServiceWeb, :controller
  alias SupportServiceWeb.Endpoint
  alias SupportService.Serve
  alias SupportService.Serve.{Ticket,TicketAssign}
  alias SupportServiceWeb.{TicketAssignView,TicketView,TicketTypeView}
  alias SupportService.Task


  action_fallback SupportServiceWeb.FallbackController
  plug :authenticate_api_user when action in [:index,:show,:update,:delete,:client_tickets]


  def index(conn, %{ "page"=> page, "numberOfObjectsPerPage" => numberOfObjectsPerPage  } ) do

    page_number = if( String.to_integer(page) == 0) do 1 else String.to_integer(page) end
    index = (  String.to_integer(numberOfObjectsPerPage) * (page_number - 1))
    number_of_objects = String.to_integer(numberOfObjectsPerPage)
    tickets = Serve.list_tickets(index,number_of_objects)
    render(conn, "index.json", tickets: tickets)
  end

  def index(conn,_param) do
    tickets = Serve.list_tickets()
    render(conn, "index.json", tickets: tickets)
  end

  def create(conn, ticket_params) do
    with {:ok, %Ticket{ ticket_assign: ticket_assign } = ticket  } <- Serve.create_ticket_and_assign(ticket_params) do

    %TicketAssign{user_id: user_id,ticket_id: ticket_id  } = ticket_assign

    ticket = insert_websocket_data_into_target_object(user_id,ticket_id,ticket)


    # {_protocol, host, port} = Task.get_domain_info()
    # websocket = "ws://#{host}:#{port}/socket"
    # topic = "room:#{user_id}"
    # receive_message = "room:ticket:#{ticket_id}:receive:message"
    # receive_status = "room:ticket:#{ticket_id}:receive:status"
    # ticket= ticket
    # |> Map.put(:websocket, websocket)
    # |> Map.put(:topic, topic)
    # |> Map.put(:receive_message, receive_message)
    # |> Map.put(:receive_status, receive_status)



      {:ok, body} = custom_encode_data(ticket)
      Endpoint.broadcast("room:#{user_id}", "room:#{user_id}:receive:new:ticket",body)
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.ticket_path(conn, :show, ticket))
      |> put_view(TicketView)
      |> render("show.json", ticket: ticket)
    end
  end

  defp custom_encode_data(data) do
    fields =[:id,:description,:ticket_assign,:updated_at,:client,:ticket_type,:ticket_status_type_id,:ticket_status_type ,:inserted_at,:websocket,:topic,:receive_message,:receive_status]
    data
      |> Map.take(fields)
      |> Poison.encode
  end


  def client_tickets(conn, %{"reference_id" => reference_id, "client_type_id" => client_type_id} = _param) do
    try do
      # IO.puts("ticker ---")
      # IO.inspect(reference_id)
      # IO.inspect(client_type_id)

      case Serve.list_ticket_for_client(reference_id , client_type_id)  do
        tickets = [_ | _] ->  render(conn,"index.json", tickets: tickets )
        _ -> render(conn, "index.json", tickets: [])

      end

      # with tickets  <- Serve.list_ticket_for_client(reference_id , client_type_id) do
      #   render(conn,"index.json", tickets: tickets )
      # else
      #   Ecto.NoResultsError -> render(conn, "index.json", ticket: [])
      # end
    rescue
      Ecto.NoResultsError -> render(conn, "index.json", ticket: [])
    end
  end



  def client_running_ticket(conn, %{"reference_id" => reference_id, "client_type_id" => client_type_id} = _param) do
    try do
      # IO.puts("ticker ---")
      # IO.inspect(reference_id)
      # IO.inspect(client_type_id)

      case Serve.ticket_running_for_client(reference_id , client_type_id)  do
        _tickets = [ %Ticket{id: ticket_id, ticket_assign: %TicketAssign{user_id: user_id } } =  ticket | _] -> ticket = insert_websocket_data_into_target_object(user_id,ticket_id,ticket)
          render(conn,"show.json", ticket: ticket )
        _ -> render(conn, "index.json", tickets: [])

      end

      # with tickets  <- Serve.list_ticket_for_client(reference_id , client_type_id) do
      #   render(conn,"index.json", tickets: tickets )
      # else
      #   Ecto.NoResultsError -> render(conn, "index.json", ticket: [])
      # end
    rescue
      Ecto.NoResultsError -> render(conn, "index.json", ticket: [])
    end
  end



  def show(conn, %{"id" => id} = _param) do
    try do
      ticket = Serve.get_ticket!(id)
      render(conn,"show.json", ticket: ticket )
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", ticket: %Ticket{})
    end
  end


  def ticket_status(conn,%{"id" => id, "ticket_status_type_id" => ticket_status_type_id} = _ticket_params) do

    # case  Serve.update_ticket_status_type(id,ticket_status_type_id) do
    #   {:ok, %Ticket{} = ticket} -> Endpoint.broadcast("room:#{user_id}", "room:#{user_id}:receive:status",body)
    #     render(conn,"show.json", ticket: ticket )
    #   _ -> render(conn,"show.json", ticket: %Ticket{} )
    # end


    with {:ok, %Ticket{id: ticket_id,ticket_assign: ticket_assign } = ticket} <- Serve.update_ticket_status_type_and_ticket_assign_status_type(id,ticket_status_type_id) do
      %TicketAssign{user_id: user_id} = ticket_assign
      {:ok, body} = custom_encode_for_ticket_data(ticket)
      Endpoint.broadcast("room:#{user_id}", "room:ticket:#{ticket_id}:receive:status",body)
      render(conn,"show.json", ticket: ticket )
    end
  end

  def ticket_types(conn , _params) do
    ticket_types = Serve.list_ticket_types()
    conn
    |> put_view(TicketTypeView)
    |> render("index.json", ticket_types: ticket_types)
  end

  defp custom_encode_for_ticket_data(data) do
    fields =[:id, :description, :ticket_type_id ,:ticket_status_type_id,:client_id,:updated_at ,:inserted_at]
    data
      |> Map.take(fields)
      |> Poison.encode
  end

  defp insert_websocket_data_into_target_object(user_id,ticket_id,target_object) do
    {_protocol, host, port} = Task.get_domain_info()
    websocket = if port == nil do
      "ws://#{host}/socket"
    else
      "ws://#{host}:#{port}/socket"
    end
    topic = "room:#{user_id}"
    receive_message = "room:ticket:#{ticket_id}:receive:message"
    receive_status = "room:ticket:#{ticket_id}:receive:status"
    push_message = "add:message"
    push_status = "add:status"
    target_object= target_object
    |> Map.put(:websocket, websocket)
    |> Map.put(:topic, topic)
    |> Map.put(:receive_message, receive_message)
    |> Map.put(:receive_status, receive_status)
    |> Map.put(:push_message, push_message)
    |> Map.put(:push_status, push_status)
    target_object
  end


end
