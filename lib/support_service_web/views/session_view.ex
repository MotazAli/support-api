defmodule SupportServiceWeb.SessionView do
  use SupportServiceWeb, :view
  alias SupportServiceWeb.SessionView

  def render("index.json", %{sessions: sessions}) do
    render_many(sessions, SessionView, "session.json")
  end

  def render("show.json", %{session: session}) do
    render_one(session, SessionView, "session.json")
  end

  def render("session.json", %{session: session})
  when session != nil and session.id != nil do
    %{
      id: session.id,
      token: session.token,
      inserted_at: session.inserted_at,
      updated_at: session.updated_at
    }
  end

  def render("session.json", %{session: _session})  do
    %{}
  end


end
