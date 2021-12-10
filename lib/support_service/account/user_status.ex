defmodule SupportService.Account.UserStatus do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "user_status" do
    #field :status_type_id, :integer
    #has_one :status_type, SupportService.Account.StatusType
    belongs_to :status_type, SupportService.Account.StatusType , foreign_key: :status_type_id, type: :integer
    belongs_to :user, SupportService.Account.User , foreign_key: :user_id, type: :string
    timestamps()

  end


  def changeset(user_status,attrs) do
    fields = [:status_type_id,:user_id] #:user_type,
    user_status
    |> cast(attrs,fields)
    |> validate_required(fields)
  end


end
