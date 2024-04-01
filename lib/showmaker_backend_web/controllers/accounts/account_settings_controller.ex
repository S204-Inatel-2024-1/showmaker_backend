defmodule ShowmakerBackendWeb.Accounts.AccountSettingsController do
  use ShowmakerBackendWeb, :controller

  alias Ecto.Changeset
  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackendWeb.Accounts.AccountAuth

  def update(conn, %{"current_password" => current_password, "account" => account_params}) do
    account = conn.assigns.current_account

    case Accounts.update_account_password(account, current_password, account_params) do
      {:ok, account} ->
        conn
        |> AccountAuth.sign_in_account(account)

      {:error, changeset} ->
        errors =
          Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

        conn
        |> put_status(:bad_request)
        |> json(%{error: %{message: "Couldn't update account's password", details: errors}})
    end
  end
end
