defmodule SupportService.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias SupportService.Repo

  alias SupportService.Account.{User,Session,UserStatus,Admin}
  alias SupportServiceWeb.Token
  alias SupportService.Work.UserWorkingState

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    query = from users in User,
    order_by: [desc: users.inserted_at]

    Repo.all(query)
    |> Repo.preload([:session,:user_status])
  end

  def list_users(page,numberOfObjectsPerPage) do
    query = from users in User,
    order_by:  [desc: users.inserted_at],
    limit: ^numberOfObjectsPerPage,
    offset: ^page

    Repo.all(query)
    |> Repo.preload([:session,:user_status])

  end


  def list_admins do
    query = from admins in Admin,
    order_by:  [desc: admins.inserted_at]

    Repo.all(query)
  end

  def list_admins(page,numberOfObjectsPerPage) do
    query = from admins in Admin,
    order_by:  [desc: admins.inserted_at],
    limit: ^numberOfObjectsPerPage,
    offset: ^page

    Repo.all(query)

  end


  def get_user_by_email_and_password(email,password) do
    query = from u in User,
    # where: u.email ==  ^email and u.password == ^password,
    where: u.email ==  type(^email, :string)  and u.password == type(^password, :string) ,
    select: u
    Repo.all(query)
    |> Repo.preload([:session,:user_status])
  end


  def get_user_by_session_token(token) do
    query = from s in Session,
    where: s.token == ^token,
    select: s

    Repo.all(query)
  end


  def get_admin_by_token(token) do
    query = from s in Admin,
    where: s.token == ^token,
    select: s

    Repo.all(query)
  end

  def get_user_status!(id), do: Repo.get!(UserStatus,id)

  def get_user_status_by_user_id(user_id) do
    query = from s in UserStatus,
    where: s.user_id == ^user_id,
    select: s

    Repo.all(query)
  end



  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload(:session)

  def get_admin!(id), do: Repo.get!(Admin, id)

  def get_admin_by_reference_id!(reference_id), do: Repo.get_by!(Admin,%{reference_id: reference_id})

  def get_user_by_email(email), do: Repo.get_by(User,%{email: email})

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    work_status_type = %SupportService.Enum.WorkStatusType{}
    user_id = Ecto.UUID.generate()
    token = Token.generate_token(user_id,"support")
    session = %Session{id: Ecto.UUID.generate() , token: token }
    user_working_state = %UserWorkingState{id: Ecto.UUID.generate(), working_status_type_id: work_status_type.ready }
    digital_password = generate_random_password()
    password = "#{digital_password}"
    %User{ id: user_id , reference_id: "Nan", password: password ,session: session ,user_working_state: user_working_state }
    |> User.changeset(attrs)
    |> Repo.insert
  end



  def create_admin(attrs \\ %{}) do
    id = Ecto.UUID.generate()
    %Admin{ id: id ,token: "Nan" }
    |> Admin.changeset(attrs)
    |> Repo.insert
  end


  defp generate_random_password do
    Enum.random(1_000_00..9_999_99)
  end



  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end


  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  # def update_user_status( user_id , status_id ) do
  #   users_status = get_user_status_by_user_id(user_id)
  #   [ user_status | _tail] = users_status
  #   %UserStatus{ user_status | status_type_id: status_id }
  #   |> Repo.update
  # end


  def create_or_update_user_status(%{"user_id" => user_id } = attrs) do
    case get_user_status_by_user_id(user_id) do
      [ %UserStatus{} = user_status | _tail] -> update_user_status(user_status,attrs)
      _ -> create_user_status(attrs)
    end
  end

  defp create_user_status(attrs) do
    user_status_id = Ecto.UUID.generate()
    %UserStatus{ id: user_status_id}
    |> UserStatus.changeset(attrs)
    |> Repo.insert
  end

  defp update_user_status( user_status , attrs ) do
    user_status
    |> UserStatus.changeset(attrs)
    |> Repo.update
  end

  # def update_user_status( %{"user_id" => user_id } = attrs ) do
  #   users_status = get_user_status_by_user_id(user_id)
  #   [ user_status | _tail] = users_status
  #   user_status
  #   |> UserStatus.changeset(attrs)
  #   |> Repo.update
  # end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end


  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
