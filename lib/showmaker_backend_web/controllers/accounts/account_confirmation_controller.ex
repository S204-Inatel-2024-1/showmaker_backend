defmodule ShowmakerBackendWeb.Accounts.AccountConfirmationController do
  use ShowmakerBackendWeb, :controller

  alias ShowmakerBackend.Contexts.Accounts

  def create(conn, %{"account" => %{"email" => email}}) do
    if account = Accounts.get_account_by_email(email) do
      Accounts.deliver_account_confirmation_instructions(
        account,
        &url(~p"/api/accounts/confirm/#{&1}")
      )
    end

    conn
    |> put_status(:created)
    |> json(%{
      data: %{
        message:
          "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly"
      }
    })
  end

  # Do not log in the account after confirmation to avoid a
  # leaked token giving the account access to the account.
  def update(conn, %{"confirm_token" => confirm_token}) do
    case Accounts.confirm_account(confirm_token) do
      {:ok, _} ->
        json(conn, %{
          data: %{
            message: "Account confirmed successfully"
          }
        })

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          error: %{
            message: "Account confirmation link is invalid or it has expired",
            details: nil
          }
        })
    end
  end
end
