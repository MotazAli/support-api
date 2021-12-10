defmodule SupportService.Account.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Account.User

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "sessions" do
    field :token , :string
    # field :user_id , :string
    belongs_to :user, User , foreign_key: :user_id, type: :string
    timestamps()
  end


  def changeset(session,attrs) do
    fields = [:token,:user]
    session
    |> cast(attrs,fields)
    |> validate_required(fields)
  end


end
