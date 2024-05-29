defmodule MoBank.Entities.TransactionType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction_type" do
    field :type, Ecto.Enum, values: [:debit_card, :credit_card, :pix]
    field :fee, :integer

    timestamps()
  end

  def changeset(tran_type, attrs) do
    tran_type
    |> cast(attrs, [:type, :fee])
  end
end
