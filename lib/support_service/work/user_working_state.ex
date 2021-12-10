defmodule SupportService.Work.UserWorkingState do
  use Ecto.Schema
  import Ecto.Changeset
  alias SupportService.Account.{User}
  alias SupportService.Work.WorkingStatusType

  @schema_prefix "dbo"
  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "user_working_state" do
    belongs_to :working_status_type, WorkingStatusType , foreign_key: :working_status_type_id, type: :integer
    belongs_to :user, User , foreign_key: :user_id, type: :string
    # has_one :ticket_assign, TicketAssign
    timestamps()
  end


  def changeset(ticket, attrs) do
    fields = [:working_status_type_id,:user_id]
    ticket
    |> cast(attrs, fields)
    # |> cast_assoc([:working_status_type,:user])
    |> validate_required(fields)
  end

end
