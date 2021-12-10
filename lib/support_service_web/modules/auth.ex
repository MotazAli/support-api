# plug module
defmodule SupportServiceWeb.Auth do

  import Plug.Conn
  # import Phoenix.Controller
  import SupportServiceWeb.Token
  alias SupportService.LocalCache
  alias SupportService.Account
  alias SupportService.Account.{Session,Admin}

  def init(opts), do: opts

  def call(conn,_opts) do
    conn = conn
    |> get_token_from_request_header
    |> case do
      {:ok, token} -> check_if_token_is_valid(token,conn)
      {:error,_value} -> assign(conn, :user_id, nil)
    end
    conn
    # |> get_claims_from_token
    # |> get_user_id_from_claims
  end

  defp check_if_token_is_valid(token,conn) do
    IO.puts("the token")
    IO.inspect(token)

    {user_id,user_type} =  get_token_claims_details(token)
    case user_type do
      {:ok , "support"} -> handle_support_auth(user_id,token,conn)
      {:ok, "admin"} -> handle_admin_auth(user_id,token,conn)
      _ -> assign(conn, :user_id, nil)
    end
    # case token_in_local_cache_exists?(token) do
    #   {:ok, user_id} -> add_token_in_local_cache_and_assign_it_in_connection(user_id,token,conn) # from cache
    #   {:error,nil} -> check_if_token_in_database_and_assign_it(token,conn) # from database
    # end
  end


  def handle_support_auth(user_id,token,conn) do
    case token_in_support_local_cache_exists?(user_id,token) do
      {:ok, user_id} -> add_token_in_support_local_cache_and_assign_it_in_connection(user_id,token,conn) # from cache
      {:error,nil} -> check_if_token_in_support_database_and_assign_it(token,conn) # from database
    end
  end

  def handle_admin_auth(user_id,token,conn) do
    case token_in_admin_local_cache_exists?(user_id,token) do
      {:ok, user_id} -> add_token_in_admin_local_cache_and_assign_it_in_connection(user_id,token,conn) # from cache
      {:error,nil} -> check_if_token_in_admin_database_and_assign_it(token,conn) # from database
    end
  end


  defp get_token_claims_details(token) do
    claims = token
    |> get_claims_from_token


    user_type = claims
    |> get_user_type_from_claims()

    user_id = claims
    |> get_user_id_from_claims


    {user_id,user_type}
  end


  defp token_in_support_local_cache_exists?(user_data ,token) do
    user_data
    |> check_if_user_id_for_support_in_local_cache
    |> case do
      {:ok, user_id, cached_token} when cached_token == token  -> {:ok, user_id}
      _unauthorized -> {:error, nil}
    end
  end


  defp token_in_admin_local_cache_exists?(user_data , token) do
    user_data
    |> check_if_user_id_for_admin_in_local_cache
    |> case do
      {:ok, user_id, cached_token} when cached_token == token  ->IO.puts("from admin cache")
        {:ok, user_id}
      _unauthorized -> {:error, nil}
    end
  end




  # defp check_if_token_in_local_cache_and_assign_it(token,conn) do
  #   token
  #   |> get_claims_from_token
  #   |> get_user_id_from_claims
  #   |> check_if_user_id_in_local_cache
  #   |> case do
  #     {:ok, user_id, cached_token} when cached_token == token  -> assign(conn, :current_user, user_id)
  #     _unauthorized -> assign(conn, :current_user, nil)
  #   end
  # end

  defp check_if_user_id_for_support_in_local_cache({:ok , user_id} = _result) do
    # IO.inspect(result)
    case LocalCache.get_support_user(user_id) do
      {:ok, token} -> {:ok, user_id ,token}
      _ -> {:error, nil}
    end
  end


  defp check_if_user_id_for_admin_in_local_cache({:ok , user_id} = _result) do

    # IO.puts(" check cache result -----")
    # IO.inspect(result)
    case LocalCache.get_admin_user(user_id) do
      {:ok, token} -> IO.inspect(token)
        {:ok, user_id ,token}
      _ -> {:error, nil}
    end
  end

  defp check_if_user_id_in_local_cache({:error,nil}), do: {:error, nil}

  defp check_if_token_in_support_database_and_assign_it(token,conn)do
    IO.puts("from support database")
    token
    |> get_user_id_from_support_database_by_token
    |> case do
      {:ok,user_id} -> add_token_in_support_local_cache_and_assign_it_in_connection(user_id,token,conn)
      _unauthorized -> assign(conn, :user_id, nil)
    end
  end


  defp check_if_token_in_admin_database_and_assign_it(token,conn)do

    token
    |> get_user_id_from_admin_database_by_token
    |> case do
      {:ok,user_id} -> IO.puts("from admin database")
        add_token_in_admin_local_cache_and_assign_it_in_connection(user_id,token,conn)
      _unauthorized -> assign(conn, :user_id, nil)
    end
  end

  defp add_token_in_support_local_cache_and_assign_it_in_connection(user_id,token,conn)do
    IO.puts("from support cache")
    LocalCache.add_support_user(user_id,token)
    conn = conn
    |> assign( :user_id, user_id)
    |> assign( :user_type, "support")
    conn
  end

  defp add_token_in_admin_local_cache_and_assign_it_in_connection(user_id,token,conn)do
    LocalCache.add_admin_user(user_id,token)
    conn = conn
    |> assign( :user_id, user_id)
    |> assign( :user_type, "admin")
    conn
  end

  defp get_token_from_request_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, nil}
    end
  end



  defp get_user_id_from_support_database_by_token(token)do
    #IO.inspect(Account.get_user_by_session_token(token))
    case Account.get_user_by_session_token(token) do
      [%Session{user_id: user_id} = _head | _tail] -> {:ok,user_id}
      _ -> {:error,nil}
    end
  end

  defp get_user_id_from_admin_database_by_token(token)do
    #IO.inspect(Account.get_user_by_session_token(token))
    case Account.get_admin_by_token(token) do
      [%Admin{reference_id: user_id} = _head | _tail] -> {:ok,user_id}
      _ -> {:error,nil}
    end
  end


  # plug function
  def authenticate_api_user(conn, _opts) do
    if Map.get(conn.assigns, :user_id) == nil do
      conn
      |> put_status(:unauthorized)
      # |> put_view(ExampleWeb.ErrorView)
      # |> render(:"401")
      # Stop any downstream transformations.
      |> put_resp_content_type("text/plain")
      |> send_resp(401, "Unauthorized")
      # |> render("show.json", error: %{"result" => "unauthorized"})
      |> halt()

    else
      conn
    end

    # if Map.get(conn.assigns, :current_user) do
    #   conn
    # else
    #   conn
    #   |> put_status(:unauthorized)
    #   # |> put_view(ExampleWeb.ErrorView)
    #   # |> render(:"401")
    #   # Stop any downstream transformations.
    #   |> put_resp_content_type("text/plain")
    #   |> send_resp(401, "unauthorized")
    #   # |> render("show.json", error: %{"result" => "unauthorized"})
    #   |> halt()
    # end
  end


end
