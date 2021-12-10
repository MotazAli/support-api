defmodule SupportService.Work do
  import Ecto.Query, warn: false
  alias SupportService.Repo
  alias SupportService.Work.{UserWorkingState,WorkingStatusType}
  



  def all_user_working_state(), do: Repo.all(UserWorkingState) |> Repo.preload(:working_status_type)

  def user_working_state!(id), do: Repo.get!(UserWorkingState,id) |> Repo.preload(:working_status_type)

  def all_working_status_types(), do: Repo.all(WorkingStatusType)

  def working_status_type!(id), do: Repo.get!(WorkingStatusType,id)

  def all_user_working_state_by_type_id(id) do
    query = from s in UserWorkingState,
    where: s.working_status_type_id == ^id,
    select: s

    query
    |> Repo.all
    |> Repo.preload(:working_status_type)
  end


  def all_user_working_state_by_user_id(id) do
    query = from s in UserWorkingState,
    where: s.user_id == ^id,
    select: s

    query
    |> Repo.all
    |> Repo.preload(:working_status_type)
  end


  # def create_user_working_state( %WorkingStatusType{}  = state , attrs \\ %{}  ) do
  #   user_working_state_id = Ecto.UUID.generate()
  #   %UserWorkingState{id: user_working_state_id , working_status_type: state }
  #   |> UserWorkingState.changeset(attrs)
  #   |> Repo.insert
  # end

  # def create_user_working_state( state_id, attrs \\ %{}  ) when Kernel.is_integer(state_id)  do
  #   user_working_state_id = Ecto.UUID.generate()
  #   %UserWorkingState{id: user_working_state_id , working_status_type_id: state_id }
  #   |> UserWorkingState.changeset(attrs)
  #   |> Repo.insert
  # end


  def create_or_update_user_working_state( %{"user_id" => user_id} = attrs) do
    case all_user_working_state_by_user_id(user_id) do
      [%UserWorkingState{} = user_working_state | _tail] -> update_user_working_state(user_working_state,attrs)
      _ -> create_user_working_state(attrs)
    end
  end

  defp create_user_working_state( attrs ) do
    user_working_state_id = Ecto.UUID.generate()
    %UserWorkingState{id: user_working_state_id  }
    |> UserWorkingState.changeset(attrs)
    |> Repo.insert
  end


  defp update_user_working_state(%UserWorkingState{} = user_working_state , attrs ) do
    user_working_state
    |> UserWorkingState.changeset(attrs)
    |> Repo.update
  end

  # def update_state_type_for_user_working_state(%UserWorkingState{} = user_working_state , state_id ) do
  #    %UserWorkingState{ user_working_state | working_status_type_id: state_id }
  #   # |> UserWorkingState.changeset(attrs)
  #   |> Repo.update
  # end

end
