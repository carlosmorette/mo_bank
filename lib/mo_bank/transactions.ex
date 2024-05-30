defmodule MoBank.Transactions do
  alias MoBank.Entities.TransactionType
  alias MoBank.Formatter

  def apply_fee(%TransactionType{} = trx_type, amount: amount) when is_float(amount) do
    fee_in_cents = amount * (trx_type.percentage_fee / 100) * 1
    amount_with_fee = Formatter.to_cents(amount + fee_in_cents)
    %{amount_with_fee: amount_with_fee, fee_in_cents: Formatter.to_cents(fee_in_cents)}
  end

  def find_trx_type(unparsed_type) do
    with {:ok, type} <- parse_transaction_type(unparsed_type) do
      if trx_type = TransactionType.find(type: type) do
        {:ok, trx_type}
      else
        {:error, :transaction_type_not_found}
      end
    end
  end

  def parse_transaction_type("P"), do: {:ok, :pix}
  def parse_transaction_type("C"), do: {:ok, :credit_card}
  def parse_transaction_type("D"), do: {:ok, :debit_card}
  def parse_transaction_type(_), do: {:error, :unknown_transaction_type}
end
