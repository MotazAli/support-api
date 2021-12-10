defmodule SupportServiceWeb.SupportChannel do
  use Phoenix.Channel

  alias SupportService.Account
  alias SupportService.Account.User


  def join("support:"<> user_id, _payload , socket) do
    case Account.get_user!(user_id) do
      %User{} = user -> join_reply_for_support(user_id,user ,socket)
        # assign(socket, :ticket_id, ticket_id )
        # {:ok, %{ channal: "room:#{ticket_id}", ticket_id: ticket_id } ,socket}
      _ -> {:error, %{reason: "No user with id " <> user_id}}
    end
  end

    def handle_in("support:add:message", %{"user_id" => user_id} = payload, socket) do
    broadcast(socket,"support:#{user_id}:receive:message", payload)
    {:reply, :ok, socket}

    # ticket_id = socket.assgins[:ticket_id]
    # Map.put(payload, :ticket_id, ticket_id)
    #  Serve.insert_message(payload)
    # broadcast(socket,"room:#{ticket_id}:receive:message", payload)
    # {:reply, :ok, socket}
  end


  # defp reply_to(ticket_id, payload , socket) do
  #   {:ok, body} = custom_encode_for_message_data(payload)
  #   broadcast(socket,"room:#{ticket_id}:receive:message", body)
  #   {:reply, :ok, socket}
  # end




  defp join_reply_for_support(user_id,data,socket) do
    case custom_encode_for_user_data(data) do
      {:ok, body} -> assign(socket, :user_id, user_id )
                {:ok, %{ channal: "support:#{user_id}", user: body } ,socket}
      _ -> {:error, %{reason: "No user with id " <> user_id}}
    end
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
