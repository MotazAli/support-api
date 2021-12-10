defmodule SupportServiceWeb.UserController do
  use SupportServiceWeb, :controller

  alias SupportService.Account
  alias SupportService.Account.{User,UserStatus,Session}
  alias SupportServiceWeb.UserStatusView
  alias SupportService.Task
  #alias SupportService.Account.User
  # alias SupportServiceWeb.Token

  action_fallback SupportServiceWeb.FallbackController
  plug :authenticate_api_user when action in [:index,:create,:show,:update,:delete]


  def index(conn, %{ "page"=> page, "numberOfObjectsPerPage" => numberOfObjectsPerPage  } ) do

    page_number = if( String.to_integer(page) == 0) do 1 else String.to_integer(page) end
    index = (  String.to_integer(numberOfObjectsPerPage) * (page_number - 1))
    number_of_objects = String.to_integer(numberOfObjectsPerPage)
    users = Account.list_users(index,number_of_objects)
    render(conn, "index.json", users: users)
  end



  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn,%{"email" => email} = user_params) do

    user_params = %{user_params | "email" => String.downcase(email)}
    %{"email" => downcase_email} = user_params

    if Account.get_user_by_email(downcase_email) == nil do
      insert_new_user(conn,user_params)
    else
      conn
      |> put_status(:conflict)
      |> json(%{"error" => "The email already registered before "})
    end


  end


def insert_new_user(conn,user_params) do
  with {:ok, %User{} = user} <- Account.create_user(user_params) do

    %User{
      id: user_id,
      name: name,
      mobile: mobile,
      gender: gender,
      email: email,
      password: password,
      country_id: country_id,
      city_id: city_id,
      image: image,
      address: address,
      session: session } = user

    %Session{token: token} = session
    Task.create_support_user_in_sender_core(user_id,name,email,password,mobile,address,country_id,city_id,image,gender,token)

    final_user = generate_websocket_details(user)
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.user_path(conn, :show, final_user))
    |> render("show.json", user: final_user)
  end
end


  def show(conn, %{"id" => id}) do

    try do
      user = Account.get_user!(id)

      # token = Token.generate_token(user.id,"support")
      # IO.inspect(token)

      # result = Token.generate_token(user.id,"support")
      # |> Token.get_claims_from_token
      # %{"user_id" => user_id} = result
      # IO.inspect( user_id )

      render(conn, "show.json", user: user)
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", user: %User{})
    end
  end


  def login(conn,%{"email" => email , "password" => password}) do
    try do
      users = Account.get_user_by_email_and_password(email,password)
      # IO.puts(user)
      # render(conn , "index.json", users: users)

      if length(users) > 0 do
        # [user] = users
        # render(conn, "show.json", user: user )
        [user] = users
        # final_user = user
        final_user = generate_websocket_details(user)
        render(conn, "show.json", user: final_user )
      else
        # render(conn, "show.json", user: %User{})
        conn
      |> put_status(:unauthorized )
      |> json(%{"error" => "Unauthorized "})
      # |>  render("show.json", error: %{"error" => "Unauthorized "})
      end

    rescue
      Ecto.NoResultsError -> render(conn, "show.json", user: %User{})
    end
  end

  def update(conn, %{"id" => id} = user_params) do
    user = Account.get_user!(id)

    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end


  def update_user_status(conn, user_params) do
    # with {:ok, %UserStatus{} = user_status} <- Account.update_user_status(user_params) do
    with {:ok, %UserStatus{} = user_status} <- Account.create_or_update_user_status(user_params) do
      render(conn, UserStatusView,"show.json", user_status: user_status)
    end
  end

  def generate_websocket_details(user) do
    %User{id: user_id} = user
    {_protocol, host, port} = Task.get_domain_info()
    websocket = if port == nil do
      "ws://#{host}/socket"
    else
      "ws://#{host}:#{port}/socket"
    end

    topic = "room:#{user_id}"
    receive_new_ticket= "room:#{user_id}:receive:new:ticket"
    final_user = user
    |> Map.put(:websocket,websocket)
    |> Map.put(:topic,topic)
    |> Map.put(:receive_new_ticket,receive_new_ticket)
    final_user
  end


end
