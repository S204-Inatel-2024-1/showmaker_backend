defmodule ShowmakerBackendWeb.Accounts.AccountConfirmationControllerTest do
  @moduledoc false

  use ShowmakerBackendWeb.ConnCase, async: true

  import ShowmakerBackend.AccountsFixtures

  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackend.Contexts.Accounts.Models.AccountToken
  alias ShowmakerBackend.Repo

  setup do
    %{account: account_fixture()}
  end

  describe "POST /api/accounts/confirm" do
    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/accounts/confirm", %{
          "account" => %{"email" => "unknown@showmaker.com"}
        })

      assert %{
               "data" => %{
                 "message" =>
                   "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly"
               }
             } = json_response(conn, 201)

      assert Repo.all(AccountToken) == []
    end

    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/api/accounts/confirm", %{
          "account" => %{"email" => account.email}
        })

      assert %{
               "data" => %{
                 "message" =>
                   "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly"
               }
             } = json_response(conn, 201)

      assert Repo.get_by!(AccountToken, account_id: account.id).context == "confirm"
    end
  end

  describe "POST /api/accounts/confirm/:confirm_token" do
    test "does not confirm email with invalid token", %{conn: conn, account: account} do
      conn = post(conn, ~p"/api/accounts/confirm/invalid")

      assert %{
               "error" => %{
                 "message" => "Account confirmation link is invalid or it has expired",
                 "details" => nil
               }
             } = json_response(conn, 400)

      refute Accounts.get_account!(account.id).confirmed_at
    end

    test "confirms the given token once", %{conn: conn, account: account} do
      confirm_token =
        extract_account_token(fn url ->
          Accounts.deliver_account_confirmation_instructions(account, url)
        end)

      conn = post(conn, ~p"/api/accounts/confirm/#{confirm_token}")

      assert %{
               "data" => %{
                 "message" => "Account confirmed successfully"
               }
             } = json_response(conn, 200)

      assert Accounts.get_account!(account.id).confirmed_at
      assert Repo.all(AccountToken) == []
    end
  end
end
