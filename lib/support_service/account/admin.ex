defmodule SupportService.Account.Admin do
  use Ecto.Schema
  import Ecto.Changeset


  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  # @derive {Jason.Encoder, only: [:id,:name,:email,:password,:image,:address,:country_id,:city_id,:websocket,:topic,:receive_new_ticket,:user_status,:session,:user_working_state]}
  schema "admins" do
    field :name, :string
    field :email, :string
    field :password, :string
    field :mobile, :string
    field :token, :string
    field :reference_id, :string

    # field :websocket, :string, virtual: true
    # field :topic, :string, virtual: true
    # field :receive_new_ticket, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    fields = [:name,:mobile,:email,:password,:reference_id,:token]

    admin
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
