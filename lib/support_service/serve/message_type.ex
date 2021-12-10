defmodule SupportService.Serve.MessageType do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Serve.{Message}

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "message_types" do
    field :type, :string
    field :arabic_type, :string
    has_many :message, Message
    timestamps()

  end

  def changeset(message_type, attrs) do
    fields = [:type,:arabic_type]
    message_type
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

end
