defmodule ShowmakerBackendWeb.AccountResetPasswordControllerTest do
  @moduledoc false

  use ShowmakerBackendWeb.ConnCase, async: true

  import ShowmakerBackend.AccountsFixtures

  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackend.Contexts.Accounts.Models.AccountToken
  alias ShowmakerBackend.Repo

  setup do
    %{account: account_fixture()}
  end

  describe "POST /api/accounts/reset_password" do
    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/accounts/reset_password", %{
          "account" => %{"email" => "unknown@showmaker.com"}
        })

      assert %{
               "data" => %{
                 "message" =>
                   "If your email is in our system, you will receive instructions to reset your password shortly"
               }
             } = json_response(conn, 201)

      assert Repo.all(AccountToken) == []
    end

    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/api/accounts/reset_password", %{
          "account" => %{"email" => account.email}
        })

      assert %{
               "data" => %{
                 "message" =>
                   "If your email is in our system, you will receive instructions to reset your password shortly"
               }
             } = json_response(conn, 201)

      assert Repo.get_by!(AccountToken, account_id: account.id).context ==
               "reset_password"
    end
  end

  describe "PUT /api/accounts/reset_password/:reset_token" do
    setup %{account: account} do
      reset_token =
        extract_account_token(fn url ->
          Accounts.deliver_account_reset_password_instructions(account, url)
        end)

      %{reset_token: reset_token}
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn =
        put(conn, ~p"/api/accounts/reset_password/invalid", %{
          "account" => %{}
        })

      assert %{
               "error" => %{
                 "message" => "Account confirmation link is invalid or it has expired",
                 "details" => nil
               }
             } = json_response(conn, 400)
    end

    test "does not reset password on invalid data", %{conn: conn, reset_token: reset_token} do
      conn =
        put(conn, ~p"/api/accounts/reset_password/#{reset_token}", %{
          "account" => %{
            "password" => "too short"
          }
        })

      assert %{
               "error" => %{
                 "message" => "Couldn't reset account's password",
                 "details" => %{
                   "password" => ["should be at least 12 character(s)"]
                 }
               }
             } = json_response(conn, 400)
    end

    test "resets password once", %{conn: conn, account: account, reset_token: reset_token} do
      conn =
        put(conn, ~p"/api/accounts/reset_password/#{reset_token}", %{
          "account" => %{
            "password" => "new valid password"
          }
        })

      assert %{
               "data" => %{
                 "message" => "Account's password changed successfully"
               }
             } = json_response(conn, 200)

      assert Accounts.get_account_by_email_and_password(account.email, "new valid password")
    end
  end
end
