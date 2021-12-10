defmodule SupportService.Work.WorkingStatusType do
  use Ecto.Schema
  alias SupportService.Work.UserWorkingState

  @schema_prefix "dbo"
  @primary_key {:id, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "working_status_types" do
    field :type, :string
    field :arabic_type, :string
    has_many :user_working_state, UserWorkingState
    timestamps()

  end


end
