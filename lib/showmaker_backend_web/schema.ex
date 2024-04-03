defmodule ShowmakerBackendWeb.Schema do
  @moduledoc """
  This module is responsible to keep the whole graphql schema, including types and resolvers
  """

  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(ShowmakerBackendWeb.Schema.Types.Account)

  query do
    import_fields(:account_queries)
  end

  mutation do
    import_fields(:account_mutations)
  end
end
