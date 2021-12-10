defmodule SupportServiceWeb.Router do
  use SupportServiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SupportServiceWeb.Auth
  end

  scope "/", SupportServiceWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", SupportServiceWeb do
    pipe_through :api

    resources "/users" , UserController
    post "/users/status", UserController, :update_user_status
    post "/users/login" , UserController , :login

    resources "/admins" , AdminController
    post "/admins/updateToken" , AdminController, :update_token

    get "/clients/types" , ClientController, :client_types_index
    resources "/clients", ClientController, only: [:index, :show]

    get "/tickets/clients" , TicketController, :client_tickets
    get "/tickets/running",TicketController , :client_running_ticket
    get "/tickets/types",TicketController , :ticket_types
    resources "/tickets" , TicketController
    resources "/tickets/assign" , TicketAssignController
    put "/tickets/:id/status" , TicketController, :ticket_status
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SupportServiceWeb.Telemetry
    end
  end
end
