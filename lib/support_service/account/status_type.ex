defmodule SupportService.Account.StatusType do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Account.UserStatus

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "status_types" do
    field :type , :string
    field :arabic_type , :string
    has_many :user_status, UserStatus
    timestamps()
  end


  def changeset(status_type,attrs) do
    fields = [:type,:arabic_type]
    status_type
    |> cast(attrs,fields)
    |> validate_required(fields)
  end


end
