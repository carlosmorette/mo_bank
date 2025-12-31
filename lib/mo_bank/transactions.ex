defmodule MoBank.Transactions do
  @moduledoc """
  Módulo responsável por gerenciar operações relacionadas a transações financeiras.

  Este módulo fornece funcionalidades para calcular taxas de transações e
  gerenciar tipos de transações.
  """
  alias MoBank.Entities.TransactionType
  alias MoBank.Formatter

  @type unparsed_type :: String.t()

  @doc """
  Função que calcula e retorna:
  - Valor da transação junto + taxa em centavos
  - Valor da taxa em centavos
  """
  @spec apply_fee(TransactionType.t(), Keyword.t()) :: map
  def apply_fee(%TransactionType{} = trx_type, amount: amount) when is_float(amount) do
    fee_in_cents = amount * (trx_type.percentage_fee / 100)
    amount_with_fee = Formatter.to_cents(amount + fee_in_cents)
    %{amount_with_fee: amount_with_fee, fee_in_cents: Formatter.to_cents(fee_in_cents)}
  end

  @doc "Função que verifica e retorna um `TransactionType`, caso exista"
  @spec find_trx_type(unparsed_type) :: {:ok, TransactionType.t()} | {:error, atom}
  def find_trx_type(unparsed_type) do
    with {:ok, type} <- parse_transaction_type(unparsed_type) do
      if trx_type = TransactionType.find(type: type) do
        {:ok, trx_type}
      else
        {:error, :transaction_type_not_found}
      end
    end
  end

  defp parse_transaction_type("P"), do: {:ok, :pix}
  defp parse_transaction_type("C"), do: {:ok, :credit_card}
  defp parse_transaction_type("D"), do: {:ok, :debit_card}
  defp parse_transaction_type(_), do: {:error, :unknown_transaction_type}
end
