defmodule SupportServiceWeb.UserView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.{UserView,SessionView,UserStatusView}

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
    # %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
    # %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user})
  when user != nil and user.id != nil do
    %{
      id: user.id,
      name: user.name,
      mobile: user.mobile,
      address: user.address,
      email: user.email,
      image: user.image,
      country_id: user.country_id,
      city_id: user.city_id,
      websocket: if user.websocket != nil do user.websocket else "" end,
      topic: if user.topic != nil do user.topic else "" end,
      receive_new_ticket: if user.receive_new_ticket != nil do user.receive_new_ticket else "" end,
      # password: user.password,
      status: render_one(user.user_status, UserStatusView, "user_status.json") ,
      session: render_one(user.session, SessionView, "session.json") ,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("user.json", %{user: _user})  do
    %{}
  end


end
