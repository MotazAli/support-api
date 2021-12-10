defmodule SupportService.Serve.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Serve.{ClientType,Ticket}

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:reference_id,:name,:client_type]}
  schema "clients" do
    field :reference_id, :string
    field :name, :string
    belongs_to :client_type, ClientType , foreign_key: :client_type_id, type: :integer
    has_many :tickets, Ticket
    timestamps()
  end


  def changeset(client, attrs) do
    # fields = [:referece_id,:name]
    fields = [:reference_id,:name,:client_type_id]
    client
    |> cast(attrs, fields)
    # |> cast_assoc(:client_type)
    |> validate_required(fields)
  end

end
