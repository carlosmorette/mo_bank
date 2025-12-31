defmodule MoBank.Entities.Transaction do
  @moduledoc """
  Módulo que define o schema e as operações relacionadas a transações financeiras.

  Este módulo representa as transações financeiras realizadas no sistema,
  incluindo informações como valor, taxas, status e contas envolvidas.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias MoBank.Entities.{Account, TransactionType}

  @fields ~w(amount fee_in_cents status sender_account_id payment_type_id)a

  schema "transactions" do
    field :amount, :integer
    field :fee_in_cents, :integer
    field :status, Ecto.Enum, values: [:inserted, :confirmed, :error]

    belongs_to :sender_account, Account, type: :string
    belongs_to :payment_type, TransactionType

    timestamps()
  end

  def create_changeset(attrs) when is_map(attrs) do
    %__MODULE__{status: :confirmed}
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:sender_account_id)
    |> foreign_key_constraint(:payment_type_id)
  end
end
