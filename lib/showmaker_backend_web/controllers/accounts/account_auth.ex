defmodule ShowmakerBackendWeb.Accounts.AccountAuth do
  @moduledoc false

  use ShowmakerBackendWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias ShowmakerBackend.Contexts.Accounts

  def sign_in_account(conn, account) do
    conn
    |> put_status(:created)
    |> json(%{
      data: %{
        access_token: Accounts.create_account_api_token(account)
      }
    })
  end

  def require_authentication(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, account} <- Accounts.fetch_account_by_api_token(token) do
      assign(conn, :current_account, account)
    else
      _error ->
        conn
        |> send_resp(:unauthorized, "No access for you")
        |> halt()
    end
  end
end
