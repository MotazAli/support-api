defmodule SupportService.Serve.ClientType do
  use Ecto.Schema
  alias SupportService.Serve.Client

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:type, :arabic_type]}
  schema "client_types" do
    field :type, :string
    field :arabic_type, :string
    has_many :client, Client
    timestamps()

  end


end
