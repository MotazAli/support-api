defmodule SupportServiceWeb.UserStatusView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.UserStatusView

  def render("index.json", %{users_status: users_status}) do
    render_many(users_status, UserStatusView, "user_status.json")
  end

  def render("show.json", %{user_status: user_status}) do
    render_one(user_status, UserStatusView, "user_status.json")
  end

  def render("user_status.json", %{user_status: user_status})
  when user_status != nil and user_status.id != nil do
    %{
      id: user_status.id,
      user_id: user_status.user_id,
      status_type_id: user_status.status_type_id,
      inserted_at: user_status.inserted_at,
      updated_at: user_status.updated_at
    }
  end

  def render("user_status.json", %{user_status: _user_status})  do
    %{}
  end


end
