defmodule SupportService.Serve.Message do

  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Serve.{Ticket,MessageType}

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "messages" do
    field :text, :string
    field :is_client, :boolean
    belongs_to :message_type, MessageType , foreign_key: :message_type_id, type: :integer
    belongs_to :ticket, Ticket , foreign_key: :ticket_id, type: :string
    timestamps()
  end


  def changeset(message, attrs) do
    # fields = [:description]
    fields = [:text,:is_client, :message_type_id, :ticket_id]
    message
    |> cast(attrs, fields)
    # |> cast_assoc([:ticket_assign])
    |> validate_required(fields)
  end

end
