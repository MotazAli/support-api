defmodule SupportService.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Account.{Session,UserStatus}
  alias SupportService.Serve.{TicketAssign}
  alias SupportService.Work.UserWorkingState


  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  # @derive {Jason.Encoder, only: [:id,:name,:email,:password,:image,:address,:country_id,:city_id,:websocket,:topic,:receive_new_ticket,:user_status,:session,:user_working_state]}
  schema "users" do
    field :name, :string
    field :mobile, :string
    field :email, :string
    field :password, :string
    field :image, :string
    field :address, :string
    field :country_id, :integer
    field :city_id, :integer
    field :reference_id, :string
    field :gender, :string

    field :websocket, :string, virtual: true
    field :topic, :string, virtual: true
    field :receive_new_ticket, :string, virtual: true

    has_one :user_status, UserStatus
    has_one :session, Session
    has_many :tickets_assign, TicketAssign
    has_one :user_working_state, UserWorkingState
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    fields = [:name,:mobile,:email,:password,:image,:address,:country_id,:city_id,:reference_id,:gender]

    user
    |> cast(attrs, fields)
    |> cast_assoc(:session)
    |> cast_assoc(:user_status)
    |> cast_assoc(:user_working_state)
    |> validate_required(fields)
  end
end
