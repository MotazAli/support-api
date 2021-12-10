defmodule SupportServiceWeb.Token do
  use Joken.Config



  def generate_token(user_id , user_type) do
    # {:ok, token_with_default_claims} = MyApp.Token.generate_and_sign()

    # extra_claims = %{"user_id" => user_id ,"user_type" => user_type, "nameid" => user_id  ,"UserType" =>user_type }
    # extra_claims = %{"user_id" => user_id ,"user_type" => user_type }
    extra_claims = %{ "nameid" => user_id  ,"UserType" =>user_type }
    case SupportServiceWeb.Token.generate_and_sign(extra_claims) do
      {:ok , token , _claims } -> token
      {:error , _reson} -> ""
    end
  end

  def generate_token!(user_id , user_type) do
    # {:ok, token_with_default_claims} = MyApp.Token.generate_and_sign()
    # extra_claims = %{"user_id" => user_id ,"user_type" => user_type }
    extra_claims = %{ "nameid" => user_id  ,"UserType" =>user_type }
    SupportServiceWeb.Token.generate_and_sign(extra_claims)
  end


  def get_claims_from_token(token \\ "") do
    # result = token
    # |> SupportServiceWeb.Token.verify_and_validate
    # IO.puts("verify_and_validate")
    # IO.inspect(Joken.peek_claims(token))
    # case SupportServiceWeb.Token.verify_and_validate(token) do
    case Joken.peek_claims(token) do
      {:ok , claims} -> claims
      {:error , _reson} -> %{}
    end

  end

  def get_claims_from_token!(token \\ "") do
    Joken.peek_claims(token)
    # SupportServiceWeb.Token.verify_and_validate(token)
  end

  def get_user_id_from_claims(claims) do
    # IO.puts("claims")
    # IO.inspect(claims)
    case claims do
      # %{"user_id" => user_id} -> {:ok,user_id}
      %{"nameid" => user_id} -> {:ok,user_id}
      _ -> {:error,nil}
    end
  end


  def get_user_type_from_claims(claims) do
    case claims do
      # %{"user_type" => user_type} -> {:ok,user_type}
      %{"UserType" => user_type} -> {:ok,String.downcase(user_type)}
      _ -> {:error,nil}
    end
  end


end
