defmodule SupportService.Serve.TicketStatusType do
  use Ecto.Schema
  alias SupportService.Serve.{Ticket,TicketAssign}

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:type,:arabic_type]}
  schema "ticket_status_types" do
    field :type, :string
    field :arabic_type, :string
    has_many :ticket, Ticket
    has_many :ticket_assign, TicketAssign
    # belongs_to :client, Client , foreign_key: :client_Type_id, type: :integer
    timestamps()

  end


end
