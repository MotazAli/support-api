defmodule SupportServiceWeb.ClientController do
  use SupportServiceWeb, :controller

  alias SupportService.Serve
  alias SupportService.Serve.Client
  alias SupportServiceWeb.ClientTypeView

  action_fallback SupportServiceWeb.FallbackController
  plug :authenticate_api_user when action in [:client_types_index,:index,:show]

  def client_types_index(conn, _params) do
    client_types = Serve.list_client_types()
    render(conn, ClientTypeView ,"index.json", client_types: client_types)
  end


  def index(conn, %{ "page"=> page, "numberOfObjectsPerPage" => numberOfObjectsPerPage  } ) do
    page_number = if( String.to_integer(page) == 0) do 1 else String.to_integer(page) end
    index = (  String.to_integer(numberOfObjectsPerPage) * (page_number - 1))
    number_of_objects = String.to_integer(numberOfObjectsPerPage)
    clients = Serve.list_clients(index,number_of_objects)
    render(conn, "index.json", clients: clients)
  end

  def index(conn,_params) do
    clients = Serve.list_clients()
    render(conn, "index.json", clients: clients)
  end


  def show(conn, %{"reference_id" => reference_id,"client_type_id" => client_type_id } = _param) do
    try do
      [ %Client{} = client | _tails ] = Serve.get_client_by_reference_id_and_type_id(reference_id,client_type_id)
      render(conn,"show.json", client: client )
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", client: %Client{})
    end
  end



  def show(conn, %{"id" => id} = _param) do
    try do
      client = Serve.get_client!(id)
      render(conn,"show.json", client: client )
    rescue
      Ecto.NoResultsError -> render(conn, "show.json", client: %Client{})
    end
  end

end
