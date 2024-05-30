defmodule MoBank.Entities.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias MoBank.Repo
  alias MoBank.Entities.{Account, TransactionType}

  schema "transactions" do
    field :amount, :integer
    field :fee_in_cents, :integer
    field :status, Ecto.Enum, values: [:inserted, :confirmed, :error]
    
    belongs_to :sender_account, Account, foreign_key: :account_number
    belongs_to :payment_type, TransactionType

    timestamps()
  end

  def changeset(trx, attrs) do
    trx
    |> cast(attrs, [])
  end

  ## TODO: spec
  def create(params) when is_map(params) do
    %__MODULE__{status: :confirmed}
    |> changeset(params)
    |> Repo.insert()
  end
end
