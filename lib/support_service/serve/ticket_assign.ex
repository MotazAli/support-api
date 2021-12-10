defmodule SupportService.Serve.TicketAssign do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Serve.{Ticket,TicketStatusType}
  alias SupportService.Account.{User}

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:ticket_id,:ticket_status_type_id,:user_id]}
  schema "ticket_assigns" do
    belongs_to :ticket, Ticket , foreign_key: :ticket_id, type: :string
    belongs_to :ticket_status_type, TicketStatusType , foreign_key: :ticket_status_type_id, type: :integer
    belongs_to :user, User , foreign_key: :user_id, type: :string
    timestamps()
  end


  def changeset(ticket_assign, attrs) do
    fields = [:ticket_id,:ticket_status_type_id,:user_id]
    ticket_assign
    |> cast(attrs, fields)
    # |> cast_assoc([:ticket_type,:ticket_status_type,:user])
    |> validate_required(fields)
  end

end
