defmodule ShowmakerBackend.Contexts.Accounts.Models.AccountToken do
  @moduledoc """
  Account token model

  This module is responsible for keeping track of stored account tokens,
  so it's possible to invalidate and sign out accounts
  """

  use Ecto.Schema

  import Ecto.Query

  alias ShowmakerBackend.Contexts.Accounts.Models.Account

  @hash_algorithm :sha256
  @rand_size 32

  @api_token_validity_in_days 30
  @confirm_validity_in_days 7
  @reset_password_validity_in_days 1

  schema "accounts_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string

    belongs_to :account, Account

    timestamps(updated_at: false)
  end

  @doc """
  The non-hashed token is sent to the account email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.
  """
  def build_token(account, context) do
    build_hashed_token(account, context, account.email)
  end

  def verify_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: account in assoc(token, :account),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == account.email,
            select: account

        {:ok, query}

      :error ->
        :error
    end
  end

  def by_token_and_context_query(token, context) do
    from __MODULE__, where: [token: ^token, context: ^context]
  end

  def by_account_and_contexts_query(account, :all) do
    from acc in __MODULE__, where: acc.account_id == ^account.id
  end

  def by_account_and_contexts_query(account, [_ | _] = contexts) do
    from acc in __MODULE__, where: acc.account_id == ^account.id and acc.context in ^contexts
  end

  defp build_hashed_token(account, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %__MODULE__{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       account_id: account.id
     }}
  end

  defp days_for_context("api-token"), do: @api_token_validity_in_days
  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days
end
