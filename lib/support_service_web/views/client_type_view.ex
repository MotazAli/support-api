defmodule SupportServiceWeb.ClientTypeView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.ClientTypeView

  def render("index.json", %{client_types: client_types}) do
    render_many(client_types, ClientTypeView, "client_type.json")
  end

  def render("show.json", %{client_type: client_type}) do
    render_one(client_type, ClientTypeView, "client_type.json")
  end

  def render("client_type.json", %{client_type: client_type})
  when client_type != nil and client_type.id != nil do
    %{
      id: client_type.id,
      type: client_type.type,
      arabic_type: client_type.arabic_type,
      inserted_at: client_type.inserted_at,
      updated_at: client_type.updated_at
    }
  end

  def render("client_type.json", %{client_type: _client_type})  do
    %{}
  end


end
