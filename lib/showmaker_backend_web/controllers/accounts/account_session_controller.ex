defmodule ShowmakerBackendWeb.Accounts.AccountSessionController do
  use ShowmakerBackendWeb, :controller

  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackend.Contexts.Accounts.Models.Account
  alias ShowmakerBackendWeb.Accounts.AccountAuth

  def create(conn, %{"account" => account_params}) do
    %{"email" => email, "password" => password} = account_params
    account = Accounts.get_account_by_email_and_password(email, password)

    case account do
      %Account{confirmed_at: confirmed_at} when not is_nil(confirmed_at) ->
        AccountAuth.sign_in_account(conn, account)

      %Account{email: email} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: %{
            message: "You must confirm your account before sign-in",
            details: %{
              description:
                "A confirmation e-mail has been sent to #{email}. Make sure to check your spams or, if you can't find, request a new confirmation e-mail"
            }
          }
        })

      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: %{
            # To prevent user enumeration attacks
            message: "Invalid email or password",
            details: nil
          }
        })
    end
  end

  def delete(conn, _params) do
    with ["Bearer " <> access_token] <- get_req_header(conn, "authorization"),
         {:ok, account} <- Accounts.fetch_account_by_api_token(access_token),
         _ <- Accounts.delete_access_token_by_account(account) do
      conn
      |> put_status(:no_content)
      |> json(%{})
    else
      _error ->
        conn
        |> put_status(:no_content)
        |> json(%{})
    end
  end
end
