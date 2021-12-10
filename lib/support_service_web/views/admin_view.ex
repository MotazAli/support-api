defmodule SupportServiceWeb.AdminView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.AdminView

  def render("index.json", %{admins: admins}) do
    render_many(admins, AdminView, "admin.json")
    # %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{admin: admin}) do
    render_one(admin, AdminView, "admin.json")
    # %{data: render_one(user, UserView, "user.json")}
  end

  def render("admin.json", %{admin: admin})
  when admin != nil and admin.id != nil do
    %{
      id: admin.id,
      name: admin.name,
      mobile: admin.mobile,
      email: admin.email,
      token: admin.token,
      password: admin.password,
      inserted_at: admin.inserted_at,
      updated_at: admin.updated_at
    }
  end

  def render("admin.json", %{admin: _admin})  do
    %{}
  end


end
