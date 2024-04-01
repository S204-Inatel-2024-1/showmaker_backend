defmodule ShowmakerBackendWeb.Accounts.AccountResetPasswordController do
  use ShowmakerBackendWeb, :controller

  alias Ecto.Changeset
  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackend.Contexts.Accounts.Models.Account

  def create(conn, %{"account" => %{"email" => email}}) do
    if account = Accounts.get_account_by_email(email) do
      Accounts.deliver_account_reset_password_instructions(
        account,
        &url(~p"/api/accounts/reset_password/#{&1}")
      )
    end

    conn
    |> put_status(:created)
    |> json(%{
      data: %{
        message:
          "If your email is in our system, you will receive instructions to reset your password shortly"
      }
    })
  end

  # Do not log in the account after reset password to avoid a
  # leaked token giving the account access to the account.
  def update(conn, %{"account" => account_params, "reset_token" => reset_token}) do
    with {:get, %Account{} = account} <-
           {:get, Accounts.get_account_by_reset_password_token(reset_token)},
         {:ok, _} <- Accounts.reset_account_password(account, account_params) do
      conn
      |> put_status(:ok)
      |> json(%{
        data: %{
          message: "Account's password changed successfully"
        }
      })
    else
      {:get, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          error: %{
            message: "Account confirmation link is invalid or it has expired",
            details: nil
          }
        })

      {:error, changeset} ->
        errors =
          Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

        conn
        |> put_status(:bad_request)
        |> json(%{error: %{message: "Couldn't reset account's password", details: errors}})

      _error ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{})
    end
  end
end
