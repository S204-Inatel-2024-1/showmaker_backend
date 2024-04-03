defmodule ShowmakerBackendWeb.Schema.Types.Account do
  @moduledoc """
  This module keeps all account related types
  """

  use Absinthe.Schema.Notation

  alias ShowmakerBackendWeb.Schema.Resolvers

  @desc "User's account"
  object :account do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :confirmed_at, :naive_datetime
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)

    # field :account_tokens, list_of(:account_token)
  end

  @desc "Account's related token"
  object :account_token do
    field :id, non_null(:id)
    field :token, non_null(:string)
    field :context, non_null(:string)
    field :sent_to, non_null(:string)
    field :account_id, non_null(:id)
    field :inserted_at, non_null(:naive_datetime)

    # field :account, :account
  end

  object :account_queries do
    field :accounts, list_of(:account)
  end

  object :account_mutations do
    field :register_account, type: :account do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.Account.register_account/3)
    end
  end
end
