defmodule ShowmakerBackendWeb.Schema.Resolvers.Account do
  @moduledoc """
  This module keep all account's related graphql resolvers
  """

  use Phoenix.VerifiedRoutes,
    router: ShowmakerBackendWeb.Router,
    endpoint: ShowmakerBackendWeb.Endpoint

  alias Ecto.Changeset
  alias ShowmakerBackend.Contexts.Accounts

  def list_accounts(_parent, _args, _resolution) do
    {:ok, Accounts.list_accounts()}
  end

  def register_account(_parent, %{email: _, password: _} = account_params, _resolution) do
    with {:ok, account} <- Accounts.register_account(account_params),
         {:ok, _} <-
           Accounts.deliver_account_confirmation_instructions(
             account,
             &url(~p"/api/accounts/confirm/#{&1}")
           ) do
      {:ok, account}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        errors =
          Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

        {
          :error,
          %{status_code: "bad_request", message: "Couldn't create account", details: errors}
        }
    end
  end
end
