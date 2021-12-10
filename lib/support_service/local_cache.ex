defmodule SupportService.LocalCache do


  def get_support_user(user_id) do
    case support_user_exists?(user_id) do
      {:ok, true} -> find_support_user(user_id)
      {:ok, false} -> {:error, nil}
    end
  end

  defp find_support_user(user_id) do
    case Cachex.get(:support_users, user_id) do
      {:ok, nil} -> {:error,nil}
      {:ok,value} -> {:ok, value}
    end
  end

  defp support_user_exists?(user_id) do
    Cachex.exists?(:support_users, user_id)
  end


  def add_support_user(user_id,value) do
    case support_user_exists?(user_id) do
      {:ok, true} -> update_support_user_expiration(user_id)
      {:ok, false} -> insert_support_user(user_id,value)
    end
  end


  defp insert_support_user(user_id,value) do
    Cachex.put(:support_users, user_id, value, ttl: :timer.minutes(30))
  end

  defp update_support_user_expiration(user_id) do
    Cachex.expire(:support_users, user_id, :timer.minutes(30))
  end



  def add_admin_user(user_id,value) do
    case admin_user_exists?(user_id) do
      {:ok, true} -> update_admin_user_expiration(user_id)
      {:ok, false} -> insert_admin_user(user_id,value)
    end
  end


  def get_admin_user(user_id) do
    case admin_user_exists?(user_id) do
      {:ok, true} -> find_admin_user(user_id)
      {:ok, false} -> {:error, nil}
    end
  end

  defp find_admin_user(user_id) do
    case Cachex.get(:admin_users, user_id) do
      {:ok, nil} -> {:error,nil}
      {:ok,value} -> {:ok, value}
    end
  end

  defp admin_user_exists?(user_id) do
    Cachex.exists?(:admin_users, user_id)
  end




  def add_admin_user(user_id,value) do
    case admin_user_exists?(user_id) do
      {:ok, true} -> update_admin_user_expiration(user_id)
      {:ok, false} -> insert_admin_user(user_id,value)
    end
  end


  defp insert_admin_user(user_id,value) do
    IO.puts("insert admin ------")
    IO.inspect(user_id)
    Cachex.put(:admin_users, user_id, value, ttl: :timer.minutes(30))
  end

  defp update_admin_user_expiration(user_id) do
    IO.puts("update admin ------")
    IO.inspect(user_id)
    Cachex.expire(:admin_users, user_id, :timer.minutes(30))
  end


end
