defmodule ShowmakerBackend.Contexts.Accounts do
  @moduledoc """
  Accounts API

  This module is responsible for any authentication
  and authorization action
  """

  import Ecto.Query, warn: false
  alias ShowmakerBackend.Repo

  alias ShowmakerBackend.Contexts.Accounts.Models.Account
  alias ShowmakerBackend.Contexts.Accounts.Models.AccountToken
  alias ShowmakerBackend.Contexts.Accounts.Notifiers.AccountNotifier

  ## Getters

  def get_account_by_email(email) when is_binary(email) do
    Repo.get_by(Account, email: email)
  end

  def get_account_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    account = Repo.get_by(Account, email: email)
    if Account.valid_password?(account, password), do: account
  end

  # credo:disable-for-next-line
  # TODO: maybe remove
  def get_account!(id), do: Repo.get!(Account, id)

  ## Registration

  def register_account(attrs) do
    %Account{}
    |> Account.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_account_password(account, attrs \\ %{}) do
    Account.password_changeset(account, attrs, hash_password: false)
  end

  def update_account_password(account, current_password, attrs) do
    changeset =
      account
      |> Account.password_changeset(attrs)
      |> Account.validate_current_password(current_password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  def create_account_api_token(account) do
    {encoded_token, account_token} = AccountToken.build_token(account, "api-token")
    Repo.insert!(account_token)
    encoded_token
  end

  def fetch_account_by_api_token(token) do
    with {:ok, query} <- AccountToken.verify_token_query(token, "api-token"),
         %Account{} = account <- Repo.one(query) do
      {:ok, account}
    else
      _ -> :error
    end
  end

  def delete_access_token_by_account(account) do
    account
    |> AccountToken.by_account_and_contexts_query(["api-token"])
    |> Repo.delete_all()

    :ok
  end

  ## Confirmation

  def deliver_account_confirmation_instructions(%Account{} = account, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if account.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, account_token} = AccountToken.build_token(account, "confirm")
      Repo.insert!(account_token)

      AccountNotifier.deliver_confirmation_instructions(
        account,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  def confirm_account(token) do
    with {:ok, query} <- AccountToken.verify_token_query(token, "confirm"),
         %Account{} = account <- Repo.one(query),
         {:ok, %{account: account}} <-
           account
           |> confirm_account_multi()
           |> Repo.transaction() do
      {:ok, account}
    else
      _error -> :error
    end
  end

  defp confirm_account_multi(account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.confirm_changeset(account))
    |> Ecto.Multi.delete_all(
      :tokens,
      AccountToken.by_account_and_contexts_query(account, ["confirm"])
    )
  end

  ## Reset password

  def deliver_account_reset_password_instructions(%Account{} = account, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_token(account, "reset_password")
    Repo.insert!(account_token)

    AccountNotifier.deliver_reset_password_instructions(
      account,
      reset_password_url_fun.(encoded_token)
    )
  end

  def get_account_by_reset_password_token(token) do
    with {:ok, query} <- AccountToken.verify_token_query(token, "reset_password"),
         %Account{} = account <- Repo.one(query) do
      account
    else
      _ -> nil
    end
  end

  def reset_account_password(account, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.password_changeset(account, attrs))
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end
end
