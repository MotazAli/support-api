defmodule SupportService.Serve.Ticket do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Serve.{Client,TicketType,TicketStatusType,TicketAssign,Message}

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:description,:ticket_type,:ticket_status_type,:ticket_assign,:websocket,:topic,:receive_message,:receive_status]}
  schema "tickets" do

    field :websocket, :string, virtual: true
    field :topic, :string, virtual: true
    field :receive_message, :string, virtual: true
    field :receive_status, :string, virtual: true
    field :push_message, :string, virtual: true
    field :push_status, :string, virtual: true

    field :description, :string
    belongs_to :ticket_type, TicketType , foreign_key: :ticket_type_id, type: :integer
    belongs_to :ticket_status_type, TicketStatusType , foreign_key: :ticket_status_type_id, type: :integer
    belongs_to :client, Client , foreign_key: :client_id, type: :string
    has_one :ticket_assign, TicketAssign
    has_many :messages, Message
    timestamps()
  end


  def changeset(ticket, attrs) do
    # fields = [:description]
    fields = [:description, :ticket_type_id, :ticket_status_type_id, :client_id]
    ticket
    |> cast(attrs, fields)
    # |> cast_assoc([:ticket_assign])
    |> validate_required(fields)
  end

end
