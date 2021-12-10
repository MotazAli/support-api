defmodule SupportServiceWeb.ClientView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.ClientView

  def render("index.json", %{clients: clients}) do
    render_many(clients, ClientView, "client.json")
  end

  def render("show.json", %{client: client}) do
    render_one(client, ClientView, "client.json")
  end

  def render("client.json", %{client: client})
  when client != nil and client.id != nil do
    %{
      id: client.id,
      reference_id: client.reference_id,
      name: client.name,
      client_type_id: client.client_type_id,
      inserted_at: client.inserted_at,
      updated_at: client.updated_at
    }
  end

  def render("client.json", %{client: _client})  do
    %{}
  end


end
