defmodule ShowmakerBackendWeb.Accounts.AccountSessionControllerTest do
  use ShowmakerBackendWeb.ConnCase, async: true

  import ShowmakerBackend.AccountsFixtures

  alias ShowmakerBackendWeb.Accounts.AccountAuth

  setup do
    %{account: account_fixture()}
  end

  describe "POST /api/accounts/sign_in" do
    test "emits error message with invalid credentials", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/api/accounts/sign_in", %{
          "account" => %{"email" => account.email, "password" => "invalid_password"}
        })

      assert %{
               "error" => %{
                 "message" => "Invalid email or password",
                 "details" => nil
               }
             } = json_response(conn, 403)
    end

    test "logs the account in", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/api/accounts/sign_in", %{
          "account" => %{"email" => account.email, "password" => valid_account_password()}
        })

      assert %{
               "data" => %{
                 "access_token" => _token
               }
             } = json_response(conn, 201)
    end
  end

  describe "DELETE /api/accounts/sign_out" do
    test "return no access when invalid token", %{conn: conn} do
      assert %{} =
               conn
               |> put_req_header("authorization", "Bearer invalid_token")
               |> delete(~p"/api/accounts/sign_out")
    end

    test "logs the account out", %{conn: conn, account: account} do
      assert %{
               "data" => %{
                 "access_token" => access_token
               }
             } =
               conn
               |> AccountAuth.sign_in_account(account)
               |> json_response(201)

      assert %{} =
               conn
               |> put_req_header("authorization", "Bearer #{access_token}")
               |> delete(~p"/api/accounts/sign_out")
               |> json_response(204)
    end
  end
end
