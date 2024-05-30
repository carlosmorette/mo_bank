defmodule MoBank.Entities.TransactionType do
  use Ecto.Schema
  import Ecto.Changeset

  alias MoBank.Repo

  schema "transaction_type" do
    field :type, Ecto.Enum, values: [:debit_card, :credit_card, :pix]
    field :percentage_fee, :integer

    timestamps()
  end

  def changeset(tran_type, attrs) do
    tran_type
    |> cast(attrs, [:type, :fee])
  end

  def get(transaction_type: transaction_type) do
    Repo.get_by(__MODULE__, transaction_type: transaction_type)
  end
end
