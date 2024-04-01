defmodule ShowmakerBackendWeb.AccountSettingsControllerTest do
  use ShowmakerBackendWeb.ConnCase, async: true

  import ShowmakerBackend.AccountsFixtures

  alias ShowmakerBackend.Contexts.Accounts
  alias ShowmakerBackendWeb.Accounts.AccountAuth

  describe "PUT /api/accounts/settings" do
    setup %{conn: conn} do
      account = account_fixture()

      %{"data" => %{"access_token" => access_token}} =
        conn
        |> AccountAuth.sign_in_account(account)
        |> json_response(201)

      %{account: account, access_token: access_token}
    end

    test "does not update password without being signed in", %{conn: conn} do
      assert %{} =
               conn
               |> put(~p"/api/accounts/settings", %{
                 "current_password" => "invalid",
                 "account" => %{
                   "password" => "too short",
                   "password_confirmation" => "does not match"
                 }
               })
    end

    test "does not update password on invalid data", %{conn: conn, access_token: access_token} do
      old_password_conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> put(~p"/api/accounts/settings", %{
          "current_password" => "invalid",
          "account" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert %{
               "error" => %{
                 "message" => "Couldn't update account's password",
                 "details" => %{
                   "current_password" => ["is not valid"],
                   "password" => ["should be at least 12 character(s)"],
                   "password_confirmation" => ["does not match password"]
                 }
               }
             } = json_response(old_password_conn, 400)
    end

    test "updates the account password and resets tokens", %{
      conn: conn,
      account: account,
      access_token: access_token
    } do
      new_password_conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> put(~p"/api/accounts/settings", %{
          "current_password" => valid_account_password(),
          "account" => %{
            "password" => "new valid password"
          }
        })

      assert %{
               "data" => %{
                 "access_token" => _token
               }
             } = json_response(new_password_conn, 201)

      assert Accounts.get_account_by_email_and_password(account.email, "new valid password")
    end
  end
end
