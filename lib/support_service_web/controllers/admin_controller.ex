defmodule SupportServiceWeb.AdminController do
  use SupportServiceWeb, :controller

  alias SupportService.Account
  alias SupportService.Account.{Admin}

  action_fallback SupportServiceWeb.FallbackController
  plug :authenticate_api_user when action in [:index,:create,:show,:update,:delete,:update_token]


  def index(conn, %{ "page"=> page, "numberOfObjectsPerPage" => numberOfObjectsPerPage  } ) do

    page_number = if( String.to_integer(page) == 0) do 1 else String.to_integer(page) end
    index = (  String.to_integer(numberOfObjectsPerPage) * (page_number - 1))
    number_of_objects = String.to_integer(numberOfObjectsPerPage)
    admins = Account.list_admins(index , number_of_objects)
    render(conn, "index.json", admins: admins)
  end

  def index(conn, _params) do
    admins = Account.list_admins()
    render(conn, "index.json", admins: admins)
  end

  def create(conn, admin_params) do

    with {:ok, %Admin{} = admin} <- Account.create_admin(admin_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.admin_path(conn, :show, admin))
      |> render("show.json", admin: admin)
    end
  end

  def show(conn, %{"id" => id}) do

    try do
      admin = Account.get_admin!(id)

      # token = Token.generate_token(user.id,"support")
      # IO.inspect(token)

      # result = Token.generate_token(user.id,"support")
      # |> Token.get_claims_from_token
      # %{"user_id" => user_id} = result
      # IO.inspect( user_id )

      render(conn, "show.json", admin: admin)
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", admin: %Admin{})
    end
  end



  def update_token(conn, %{"reference_id" => reference_id} = admin_params) do
    admin = Account.get_admin_by_reference_id!(reference_id)

    with {:ok, %Admin{} = admin} <- Account.update_admin(admin, admin_params) do
      render(conn, "show.json", admin: admin)
    end
  end


  def update(conn, %{"id" => id} = admin_params) do
    admin = Account.get_admin!(id)

    with {:ok, %Admin{} = admin} <- Account.update_user(admin, admin_params) do
      render(conn, "show.json", admin: admin)
    end
  end

  def delete(conn, %{"id" => id}) do
    admin = Account.get_admin!(id)

    with {:ok, %Admin{}} <- Account.delete_admin(admin) do
      send_resp(conn, :no_content, "")
    end
  end


end
