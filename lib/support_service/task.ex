defmodule SupportService.Task do
  alias SupportService.Account


  def register_service_in_gateway do
    url = "http://localhost:3000/registerService"
    {protocol,host,port} = get_domain_info()
    headers = [{"Content-Type", "application/json"}]
    # {:ok, body} = Poison.encode( %{ "name"=> "support_service", "host"=> "localhost", "protocol" => "http" , "port" => "4000" })
    {:ok, body} = Poison.encode( %{ "name"=> "support_service", "host"=> host, "protocol" => protocol , "port" => port })
    options = []
    request_info = %HTTPoison.Request{
      method: :post,
      url: url,
      body: body,
      headers: headers,
      options: options
    }

    result = HTTPoison.request(request_info)
    case result do
      {:ok, %HTTPoison.Response{ body: body } } -> IO.inspect(body)
      {:error, reason} -> IO.inspect(reason)
    end

  end

  def get_domain_info do
    current_domain = SupportServiceWeb.Endpoint.url()
    # current_domain = "https://sender-support-dev.gigalixirapp.com"
    arr = String.split(current_domain,":", trim: true)

    tuple_url = if Enum.count(arr) == 3 do
      protocol = Enum.at(arr,0)
      host = arr
      |> Enum.at(1)
      |> String.replace("//","")
      |> String.trim
      port = Enum.at(arr,2)
      {protocol,host,port}
    else
      protocol = Enum.at(arr,0)
      host = arr
      |> Enum.at(1)
      |> String.replace("//","")
      |> String.trim
      port = nil
      {protocol,host,port}
    end
    tuple_url

  end


  def create_support_user_in_sender_core(id,name,email,password,mobile,address,country_id,city_id,image,gender,user_token) do


    # token = get_sender_local_token()
    # base_url = "http://localhost:5001"


    token = get_sender_dev_token()
    base_url = "https://sender-dev-api.azurewebsites.net"


    # token = get_sender_live_token()
    # base_url = "https://sender-api.azurewebsites.net"

    url = "#{base_url}/supports/users"

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]

    {:ok, body} = Poison.encode( %{ "fullname"=> name,
     "email"=> email, "mobile" => mobile , "password" => password,
     "address" => address , "countryId" => country_id,
      "cityId" => city_id , "image" => image ,
      "gender" => gender ,"token" => user_token })
    options = []
    request_info = %HTTPoison.Request{
      method: :post,
      url: url,
      body: body,
      headers: headers,
      options: options
    }

    #start async task to save data in data base
    Task.start(fn ->
      user_id = id
      result = HTTPoison.request(request_info)
                case result do
                  {:ok, %HTTPoison.Response{ body: body } } -> update_user_reference_id(user_id,body)
                  {:error, reason} -> IO.inspect(reason)
                end
    end)
  end


  defp update_user_reference_id(user_id,body) do
     IO.inspect(body)
     with {:ok,  response} <-  Poison.decode(body) do
      IO.inspect(response)
      %{"supportId" => id} = response
      attr = %{"reference_id" =>  "#{id}"}
      IO.puts(" real user ---------")
      IO.inspect(user_id)
      # user = Account.get_user!(user_id)
      # IO.inspect(user)
      # Account.update_user(user,attr)
      Account.get_user!(user_id)
      |> Account.update_user(attr)
     end
  end

  defp get_sender_local_token do
    "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIxIiwidW5pcXVlX25hbWUiOiJ0ZXN0IGFkbWluIiwiVXNlclR5cGUiOiJBZG1pbiIsIm5iZiI6MTYzMzYzNDQ5MiwiZXhwIjoxNjMzNjM4MDkyLCJpYXQiOjE2MzM2MzQ0OTJ9.jDtde5XXmtMGBvB0tkJg5MGO4LNneOEQvRPB3Wlqxi8WmflcV2OBadLfw4by5_Mg4qvJDD8ZyEuh0CtBuE5Q7Q"
  end

  defp get_sender_dev_token do
    "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIxIiwidW5pcXVlX25hbWUiOiJTeXN0ZW0iLCJVc2VyVHlwZSI6IkFkbWluIiwibmJmIjoxNjMzNjc2OTcwLCJleHAiOjE2MzM2ODA1NzAsImlhdCI6MTYzMzY3Njk3MH0.UVdRATIWpaAEovC4vpXQ1e7CKSP4ZJsJvAyHD5ePI4-jRKRfwHJiIdDAK6fl1OBn8mbSR2Fl3JzsXM_I0XLCww"
  end

  defp get_sender_live_token do
    "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIxIiwidW5pcXVlX25hbWUiOiJ0ZXN0IGFkbWluIiwiVXNlclR5cGUiOiJBZG1pbiIsIm5iZiI6MTYzMzYzNDQ5MiwiZXhwIjoxNjMzNjM4MDkyLCJpYXQiOjE2MzM2MzQ0OTJ9.jDtde5XXmtMGBvB0tkJg5MGO4LNneOEQvRPB3Wlqxi8WmflcV2OBadLfw4by5_Mg4qvJDD8ZyEuh0CtBuE5Q7Q"
  end

end
