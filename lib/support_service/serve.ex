defmodule SupportService.Serve do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias SupportService.Repo

  alias SupportService.Serve.{Client,ClientType,Ticket,TicketType,TicketStatusType,TicketAssign,Message,MessageType}
  alias SupportService.Enum.{WorkStatusType}
  alias SupportService.Work
  alias SupportService.Work.UserWorkingState
  alias SupportService.Task
  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """


  def list_clients do
    query = from clients in Client,
    order_by: [desc: clients.inserted_at]

    Repo.all(query)
    |> Repo.preload(:client_type)
  end


  def list_clients(page,numberOfObjectsPerPage) do
    query = from clients in Client,
    order_by: [desc: clients.inserted_at],
    limit: ^numberOfObjectsPerPage,
    offset: ^page

    Repo.all(query)
    |> Repo.preload(:client_type)
  end


  def list_client_types do
    Repo.all(ClientType)
  end


  def list_tickets do
    query = from tickets in Ticket,
    order_by: [desc: tickets.inserted_at]

    Repo.all(query)
    |> Repo.preload([:ticket_assign,:ticket_type,:ticket_status_type,client: :client_type ])
  end

  def list_tickets(page,numberOfObjectsPerPage) do
    query = from tickets in Ticket,
    order_by: [desc: tickets.inserted_at],
    limit: ^numberOfObjectsPerPage,
    offset: ^page

    Repo.all(query)
    |> Repo.preload([:ticket_assign,:ticket_type,:ticket_status_type,client: :client_type ])
  end

  def list_tickets_assigns do
    Repo.all(TicketAssign)
    |> Repo.preload([:user,:ticket,:ticket_status_type])
  end

  def list_ticket_types, do: Repo.all(TicketType)
  def list_ticket_status_types, do: Repo.all(TicketStatusType)

  def list_ticket_for_client(reference_id, client_type_id) do
    case get_client_by_reference_id_and_type_id(reference_id,client_type_id) do
      [ %Client{id: client_id} | _tails ] -> list_ticket_for_client(client_id)
      _ ->  {:ok , [] }
    end
  end



  def list_ticket_for_client(client_id) do

    IO.inspect("im Ticket query start")

    query = from t in Ticket,
    where: t.client_id == ^client_id,
    select: t

    result = Repo.all(query)
     |> Repo.preload([:ticket_assign,:ticket_type,:ticket_status_type,client: :client_type ])

    # IO.inspect("end Ticket query end")
    # IO.inspect(result)
    result
  end



  def ticket_running_for_client(reference_id, client_type_id) do
    case get_client_by_reference_id_and_type_id(reference_id,client_type_id) do
      [ %Client{id: client_id} | _tails ] -> ticket_running(client_id)
      _ ->  {:ok , [] }
    end
  end

  def ticket_running(client_id) do


    ticket_status_type = %SupportService.Enum.TicketStatusType{}
    query = from tickets in Ticket,
    where: tickets.client_id == ^client_id and tickets.ticket_status_type_id != ^ticket_status_type.closed,
    select: tickets

    Repo.all(query)
    |> Repo.preload([:ticket_assign,:ticket_type,:ticket_status_type,:messages,client: :client_type ])


  end


  def list_messages, do: Repo.all(Message) |> Repo.preload(:message_type)


  def list_messages!(id), do: Repo.get!(Message , id) |> Repo.preload(:message_type)


  def list_messages_by_ticket_id(ticket_id) do
    query = from m in Message,
    where: m.ticket_id == ^ticket_id,
    select: m

    Repo.all(query)
    |> Repo.preload(:message_type)
  end

  def list_message_types, do: Repo.all(MessageType)




  def get_client_by_name(name) do
    query = from c in Client,
    where: c.name ==  ^name ,
    # where: u.email ==  type(^email, :string)  and u.password == type(^password, :string) ,
    select: c
    Repo.all(query)
    |> Repo.preload(:client_type)
  end

  def get_client_by_reference_id_and_type_id(reference_id,client_type_id) do
    query = from c in Client,
    where: c.reference_id == ^reference_id and c.client_type_id == ^client_type_id ,
    # left_join: client_type in assoc(c, :client_type),
    # preload: [client_type: :client_type]
    select: c


    # IO.inspect("im client query start")

    Repo.all(query)
    |> Repo.preload([:client_type])

  end


  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(id), do: Repo.get!(Client, id) |> Repo.preload(:client_type)

  def get_client_type!(id), do: Repo.get!(ClientType,id)

  def get_ticket!(id) do
    Repo.get!(Ticket, id)
    |> Repo.preload([:ticket_assign,:ticket_type,:ticket_status_type,client: :client_type])
  end

  def get_ticket_assign!(id) do
    Repo.get!(TicketAssign, id)
    |> Repo.preload([:user,:ticket,:ticket_status_type])
  end

  def get_ticket_type!(id), do: Repo.get!(TicketType,id)
  def get_ticket_status_type!(id), do: Repo.get!(TicketStatusType,id)





  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    client_id = Ecto.UUID.generate()
    %Client{ id: client_id}
    |> Client.changeset(attrs)
    |> Repo.insert
  end

  def create_ticket(attrs \\ %{}) do
    ticket_id = Ecto.UUID.generate()
    %Ticket{ id: ticket_id }
    |> Ticket.changeset(attrs)
    |> Repo.insert
  end

  def create_ticket_assign(attrs \\ %{}) do
    ticket_assign_id = Ecto.UUID.generate()
    %TicketAssign{ id: ticket_assign_id}
    |> TicketAssign.changeset(attrs)
    |> Repo.insert
  end


  def create_ticket_and_assign(attrs) do

    ticket_status_type = %SupportService.Enum.TicketStatusType{}
    %Client{ id: client_id }  = insert_client_if_not_exists(attrs)

    attrs = attrs
    |> Map.put("client_id", client_id)
    |> Map.put("ticket_status_type_id",ticket_status_type.new)

    # IO.inspect("this is mapppppp",attrs)

    {:ok , %Ticket{id: ticket_id} } = create_ticket(attrs)


    # assigned_user = get_assigned_user()
    user_id = get_assigned_user()

    ticket = if user_id != nil do
      # %UserWorkingState{user_id: user_id} = assigned_user

      work_status_type = %WorkStatusType{}
      %{"user_id" => user_id, "working_status_type_id" => work_status_type.progress}
      |> Work.create_or_update_user_working_state

      %{"ticket_id" => ticket_id , "user_id" => user_id , "ticket_status_type_id" => ticket_status_type.assigned }
      |> create_ticket_assign

      update_ticket_status_type(ticket_id,ticket_status_type.assigned)

    else
      %{ "ticket_id" => ticket_id, "ticket_status_type_id" => ticket_status_type.not_assigned }
      |> create_ticket_assign

      update_ticket_status_type(ticket_id,ticket_status_type.not_assigned)

    end

    ticket

    # {:ok, %TicketAssign{user_id: user_id,ticket_id: ticket_id} = ticket_assign} = ticket_assign_result
    # {_protocol, host, port} = Task.get_domain_info()
    # websocket = "ws://#{host}:#{port}/socket"
    # topic = "room:#{user_id}"
    # receive_message = "room:ticket:#{ticket_id}:receive:message"
    # receive_status = "room:ticket:#{ticket_id}:receive:status"
    # final_ticket_assign = ticket_assign
    # |> Map.put(:websocket, websocket)
    # |> Map.put(:topic, topic)
    # |> Map.put(:receive_message, receive_message)
    # |> Map.put(:receive_status, receive_status)
    # {:ok , final_ticket_assign}

    # {:ok ,%TicketAssign{} = ticket_assign  } = ticket_assign_result
    # ticket_assign
  end


  def get_less_user_with_tickets_assigned do

    ticket_status_type = %SupportService.Enum.TicketStatusType{}

    query = from ticket_assgin in TicketAssign,
    where: ticket_assgin.ticket_status_type_id == ^ticket_status_type.assigned,
    group_by: ticket_assgin.user_id,
    order_by:  [asc: count(ticket_assgin.ticket_id)],
    limit: 1,
    select: {ticket_assgin.user_id ,count(ticket_assgin.ticket_id)}

    result = Repo.all(query)
    IO.inspect(result)
    [user] = result
    {user_id,_} = user
    user_id
    # IO.puts("start user ------")
    # IO.inspect(user_id)
    # IO.puts("end user ------")
  end



  # defp get_assigned_user() do
  #   work_status_type = %WorkStatusType{}
  #   # all_ready_users = Work.all_user_working_state_by_type_id(work_status_type.ready)
  #   # IO.inspect("the arrrrrrrrray", all_ready_users)


  #   case Work.all_user_working_state_by_type_id(work_status_type.ready) do
  #     nil -> case  Work.all_user_working_state_by_type_id(work_status_type.progress) do
  #             [ %UserWorkingState{} = progress_user |_tails ] -> progress_user
  #             _ -> nil
  #             end
  #    [ %UserWorkingState{ } = ready_user |_tails ] -> ready_user
  #    [] -> case  Work.all_user_working_state_by_type_id(work_status_type.progress) do
  #             [ %UserWorkingState{} = progress_user |_tails ] -> progress_user
  #             _ -> nil
  #          end
  #    {:error, _reson} -> case  Work.all_user_working_state_by_type_id(work_status_type.progress) do
  #           [ %UserWorkingState{} = progress_user |_tails ] -> progress_user
  #           _ -> nil
  #        end

  #   end


  #   # assigned_user = if [ %UserWorkingState{} = ready_user |_tails ] = all_ready_users do
  #   #   ready_user
  #   # else
  #   #   case  Work.all_user_working_state_by_type_id(work_status_type.progress) do
  #   #     [ %UserWorkingState{} = progress_user |_tails ] -> progress_user
  #   #     _ -> nil
  #   #   end
  #   # end
  #   # assigned_user
  # end


  defp get_assigned_user() do
    work_status_type = %WorkStatusType{}
    # all_ready_users = Work.all_user_working_state_by_type_id(work_status_type.ready)
    # IO.inspect("the arrrrrrrrray", all_ready_users)


    case Work.all_user_working_state_by_type_id(work_status_type.ready) do
      nil -> case  get_less_user_with_tickets_assigned() do
              user_id when user_id != "" -> user_id
              _ -> nil
              end
     [ %UserWorkingState{ user_id: user_id } = _ready_user |_tails ] -> user_id
     [] -> case  get_less_user_with_tickets_assigned() do
              user_id when user_id != "" -> user_id
              _ -> nil
           end
     {:error, _reson} -> case  get_less_user_with_tickets_assigned() do
            user_id when user_id != "" -> user_id
            _ -> nil
         end

    end
  end

  def insert_client_if_not_exists(%{"reference_id" => reference_id,"client_type_id" => client_type_id} = attrs) do
    case get_client_by_reference_id_and_type_id(reference_id,client_type_id) do
      [ %Client{} = client | _tails ] -> client
      _ ->  case create_client(attrs) do
              {:ok , %Client{} = client } -> client
            end
    end
  end


  def insert_message(attrs) do
    message_id = Ecto.UUID.generate()
    %Message{ id: message_id }
    |> Message.changeset(attrs)
    |> Repo.insert
  end



  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update
  end

  def update_ticket_assign(%TicketAssign{} = ticket_assign, attrs) do
    ticket_assign
    |> TicketAssign.changeset(attrs)
    |> Repo.update
  end


  def update_ticket_status_type_and_ticket_assign_status_type(id,ticket_status_type_id) do
    try do
      Repo.get_by!(TicketAssign, ticket_id: id)
      |> update_ticket_assign(%{ticket_status_type_id: ticket_status_type_id})

      # IO.inspect(ticket_assign)
      # get_ticket!(id)
      Repo.get!(Ticket,id)
      |> update_ticket(%{ticket_status_type_id: ticket_status_type_id})

      {:ok, get_ticket!(id)}
    rescue
      TryClauseError -> {:error, nil}
    end
  end



  def update_ticket_status_type(id,ticket_status_type_id) do
    try do
      # Repo.get_by!(TicketAssign, ticket_id: id)
      # |> update_ticket_assign(%{ticket_status_type_id: ticket_status_type_id})

      # IO.inspect(ticket_assign)
      # get_ticket!(id)
      Repo.get!(Ticket,id)
      |> update_ticket(%{ticket_status_type_id: ticket_status_type_id})

      {:ok, get_ticket!(id)}
    rescue
      TryClauseError -> {:error, nil}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = user) do
    Repo.delete(user)
  end

  def delete_ticket(%Ticket{} = ticket ), do: ticket |> Repo.delete

  def delete_ticket_assign(%TicketAssign{} = ticket_assign), do: ticket_assign |> Repo.delete

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end
end
