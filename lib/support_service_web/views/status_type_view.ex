defmodule SupportServiceWeb.StatusTypeView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.StatusTypeView

  def render("index.json", %{status_types: status_types}) do
    render_many(status_types, StatusTypeView, "status_type.json")
  end

  def render("show.json", %{status_type: status_type}) do
    render_one(status_type, StatusTypeView, "status_type.json")
  end

  def render("status_type.json", %{status_type: status_type})
  when status_type != nil and status_type.id != nil do
    %{
      id: status_type.id,
      type: status_type.type,
      arabic_type: status_type.arabic_type,
      inserted_at: status_type.inserted_at,
      updated_at: status_type.updated_at
    }
  end

  def render("status_type.json", %{status_type: _status_type})  do
    %{}
  end


end
