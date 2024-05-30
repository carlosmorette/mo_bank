defmodule MoBank.Transactions do
  alias MoBank.Entities.TransactionType
  alias MoBank.Formatter

  def apply_fee(%TransactionType{} = trx_type, amount: amount) when is_float(amount) do
    fee_in_cents = amount * (trx_type.percentage_fee / 100) * 1
    amount_with_fee = Formatter.to_cents(amount + fee_in_cents)
    %{amount_with_fee: amount_with_fee, fee_in_cents: Formatter.to_cents(fee_in_cents)}
  end
end
