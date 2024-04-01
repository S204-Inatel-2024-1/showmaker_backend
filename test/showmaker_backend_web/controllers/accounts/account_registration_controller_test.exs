defmodule ShowmakerBackendWeb.Accounts.AccountRegistrationControllerTest do
  @moduledoc false

  use ShowmakerBackendWeb.ConnCase, async: true

  import ShowmakerBackend.AccountsFixtures

  describe "POST /api/accounts/register" do
    @tag :capture_log
    test "creates account and logs the account in", %{conn: conn} do
      email = unique_account_email()

      conn =
        post(conn, ~p"/api/accounts/register", %{
          "account" => valid_account_attributes(email: email)
        })

      assert %{
               "data" => %{
                 "message" => "Account created successfully"
               }
             } = json_response(conn, 201)
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/api/accounts/register", %{
          "account" => %{"email" => "with spaces", "password" => "too short"}
        })

      assert %{
               "error" => %{
                 "message" => "Couldn't create account",
                 "details" => %{
                   "email" => ["must have the @ sign and no spaces"],
                   "password" => ["should be at least 12 character(s)"]
                 }
               }
             } = json_response(conn, 400)
    end
  end
end
