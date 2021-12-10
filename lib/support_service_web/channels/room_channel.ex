defmodule SupportServiceWeb.RoomChannel do
  use Phoenix.Channel

  alias SupportServiceWeb.Endpoint
  alias SupportService.Serve
  alias SupportService.Account
  alias SupportService.Account.User
  alias SupportService.Serve.Ticket
  alias SupportService.Serve.{Message}


  def join("room:"<> user_id, _payload , socket) do
    case Account.get_user!(user_id) do
      %User{} = user -> join_reply_for_support(user_id,user ,socket)
        # assign(socket, :ticket_id, ticket_id )
        # {:ok, %{ channal: "room:#{ticket_id}", ticket_id: ticket_id } ,socket}
      _ -> {:error, %{reason: "No user with id " <> user_id}}
    end
  end

  defp join_reply_for_support(user_id,data,socket) do
    case custom_encode_for_user_data(data) do
      {:ok, body} -> assign(socket, :user_id, user_id )
                {:ok, %{ channal: "support:#{user_id}", user: body } ,socket}
      _ -> {:error, %{reason: "No user with id " <> user_id}}
    end
  end

  # def join("room:"<> ticket_id, _payload , socket) do
  #   case Serve.get_ticket!(ticket_id) do
  #     %Ticket{} = ticket -> join_reply(ticket_id,ticket ,socket)
  #       # assign(socket, :ticket_id, ticket_id )
  #       # {:ok, %{ channal: "room:#{ticket_id}", ticket_id: ticket_id } ,socket}
  #     _ -> {:error, %{reason: "No ticket with number " <> ticket_id}}
  #   end
  # end

  def handle_in("add:message", %{"ticket_id" => ticket_id  } =  payload, socket) do
    case Serve.insert_message(payload) do
    {:ok , %Message{} = message } -> reply_to(ticket_id,message,socket)
    _ -> {:reply, :error, socket}
    end

    # ticket_id = socket.assgins[:ticket_id]
    # Map.put(payload, :ticket_id, ticket_id)
    #  Serve.insert_message(payload)
    # broadcast(socket,"room:#{ticket_id}:receive:message", payload)
    # {:reply, :ok, socket}
  end

  def handle_in("add:status", %{"ticket_id" => ticket_id , "ticket_status_type_id" => ticket_status_type_id  } =  _payload, socket) do
    # ticket_status_type = %SupportService.Enum.TicketStatusType{}
    case Serve.update_ticket_status_type_and_ticket_assign_status_type(ticket_id,ticket_status_type_id) do
    {:ok , %Ticket{} = ticket } -> reply_to_status_event(ticket_id,ticket,socket)
    _ -> {:reply, :error, socket}
    end
  end

  # def handle_in("new:ticket:message", %{"user_id" => user_id  } =  payload, socket) do
  #   broadcast(socket,"new:ticket:room:#{user_id}:receive:message", payload)
  #   {:reply, :ok, socket}
  #   # ticket_id = socket.assgins[:ticket_id]
  #   # Map.put(payload, :ticket_id, ticket_id)
  #   #  Serve.insert_message(payload)
  #   # broadcast(socket,"room:#{ticket_id}:receive:message", payload)
  #   # {:reply, :ok, socket}
  # end

  defp reply_to(ticket_id, payload , socket) do
    # payload = Map.put(payload,:user_id ,user_id)

    {:ok, body} = custom_encode_for_message_data(payload)
    # Endpoint.broadcast_from(self() ,"support:0d9621a1-f8fb-4c31-9d31-06fdb9541100","support:add:message",body)
    broadcast(socket,"room:ticket:#{ticket_id}:receive:message", body)
    {:reply, :ok, socket}
  end


  defp reply_to_status_event(ticket_id, payload , socket) do
    # payload = Map.put(payload,:user_id ,user_id)

    {:ok, body} = custom_encode_for_ticket_data(payload)
    # Endpoint.broadcast_from(self() ,"support:0d9621a1-f8fb-4c31-9d31-06fdb9541100","support:add:message",body)
    broadcast(socket,"room:ticket:#{ticket_id}:receive:status", body)
    {:reply, :ok, socket}
  end


  defp custom_encode_for_message_data(data) do
    fields =[:id,:user_id , :ticket_id, :message_type_id ,:text,:is_client,:updated_at ,:inserted_at]
    data
      |> Map.take(fields)
      |> Poison.encode
  end

  # defp join_reply(ticket_id,data,socket) do
  #   case custom_encode_for_ticket_data(data) do
  #     {:ok, body} -> assign(socket, :ticket_id, ticket_id )
  #               {:ok, %{ channal: "room:#{ticket_id}", ticket: body } ,socket}
  #     _ -> {:error, %{reason: "No ticket with number " <> ticket_id}}
  #   end
  # end

  defp custom_encode_for_ticket_data(data) do
    fields =[:id, :description, :ticket_type_id ,:ticket_status_type_id,:client_id,:updated_at ,:inserted_at]
    data
      |> Map.take(fields)
      |> Poison.encode
  end


  defp custom_encode_for_user_data(data) do
    fields =[:id, :name, :mobile]
    data
      |> Map.take(fields)
      |> Poison.encode
  end

  # def join("room:"<> ticket_id, _payload , socket) do
  #   # messages = Serve.list_messages_by_ticket_id(ticket_id)

  #   case Serve.get_ticket!(ticket_id) do
  #     %Ticket{} = _ticket -> assign(socket, :ticket_id, ticket_id )
  #       {:ok, %{channal: "room:#{ticket_id}"} ,socket}
  #     _ -> {:error, %{reason: "No ticket with number " <> ticket_id}}
  #   end




  #   # {:ok, socket}
  #   # {:error, %{reason: "unauthorized"}}
  # end



  # def handle_in("new_msg", payload, socket) do
  #   ticket_id = socket.assgins[:ticket_id]
  #   # %{ topic: "room:" <> ticket_id } = socket
  #   Map.put(payload, :ticket_id, ticket_id)
  #   Serve.insert_message(payload)
  #   broadcast(socket,"receive_msg", payload)
  #   {:noreply,socket}
  # end



end
