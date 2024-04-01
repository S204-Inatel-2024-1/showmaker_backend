defmodule ShowmakerBackend.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ShowmakerBackend.Accounts` context.
  """

  alias ShowmakerBackend.Contexts.Accounts

  def unique_account_email, do: "account#{System.unique_integer()}@showmaker.com"
  def valid_account_password, do: "S3nha5uP3rSeCr3T4"

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_account_email(),
      password: valid_account_password()
    })
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> valid_account_attributes()
      |> Accounts.register_account()

    account
  end

  def extract_account_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
