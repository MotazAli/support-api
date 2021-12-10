defmodule SupportService.Serve.TicketType do
  use Ecto.Schema
  alias SupportService.Serve.{Ticket}

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:type,:arabic_type]}
  schema "ticket_types" do
    field :type, :string
    field :arabic_type, :string
    has_many :ticket, Ticket
    # belongs_to :client, Client , foreign_key: :client_Type_id, type: :integer
    timestamps()

  end


end
