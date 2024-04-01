defmodule ShowmakerBackendWeb.Accounts.AccountRegistrationController do
  use ShowmakerBackendWeb, :controller

  alias Ecto.Changeset
  alias ShowmakerBackend.Contexts.Accounts

  def create(conn, %{"account" => account_params}) do
    with {:ok, account} <- Accounts.register_account(account_params),
         {:ok, _} <-
           Accounts.deliver_account_confirmation_instructions(
             account,
             &url(~p"/api/accounts/confirm/#{&1}")
           ) do
      conn
      |> put_status(:created)
      |> json(%{
        data: %{
          message: "Account created successfully"
        }
      })
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        errors =
          Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

        conn
        |> put_status(:bad_request)
        |> json(%{error: %{message: "Couldn't create account", details: errors}})
    end
  end
end
