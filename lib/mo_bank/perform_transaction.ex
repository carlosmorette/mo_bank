defmodule MoBank.PerformTransaction do
  use Params

  alias MoBank.{Repo, Formatter, Transactions}
  alias MoBank.Entities.{Account, TransactionType, Transaction}

  defparams(
    perform_transaction_params(%{
      forma_pagamento!: :string,
      numero_conta!: :integer,
      valor!: :float
    })
  )

  def run(external_params) do
    Repo.transaction(fn ->
      with {:ok, params} <- validate_and_format_external_params(external_params),
           {:ok, account} <- find_account(params.account_id),
           true <- has_sufficient_balance?(account, params.amount.transaction_data.amount) do
        case send_transaction(account, params) do
          {:ok, map} -> {:ok, format_to_return(map)}
          _another_result -> {:error, :unknown_error}
        end
      else
        false ->
          {:error, :insufficient_balance}

        {:error, error} ->
          {:error, error}
      end
    end)
  end

  def send_transaction(account, params) do
    create_trx_params = %{
      fee_in_cents: params.transaction_data.fee_in_cents,
      amount: params.transaction_data.amount,
      payment_type_id: params.transaction_data.payment_type_id,
      sender_account_id: account.account_number
    }

    with {:ok, account} <- Account.decrease_balance(account, amount: params.transaction_data.amount),
         {:ok, _trx} <- Transaction.create(create_trx_params) do
      {:ok, %{account: account}}
    end
  end

  def format_to_return(%{account: account}) do
    %{
      numero_conta: account.account_number,
      saldo: Formatter.to_float(account.balance)
    }
  end

  def find_account(id) do
    if account = Account.find_for_update(id: id) do
      {:ok, account}
    else
      {:error, :account_not_found}
    end
  end

  def has_sufficient_balance?(%Account{} = account, transaction_amount)
      when is_integer(transaction_amount) do
    account.balance >= transaction_amount
  end

  def validate_and_format_external_params(data) do
    case perform_transaction_params(data) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, format_transaction_info(changeset)}

      changeset ->
        {:error, Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)}
    end
  end

  def format_transaction_info(%Ecto.Changeset{} = changeset) do
    base_params = %{
      transaction_type: changeset.changes.forma_pagamento,
      account_id: changeset.changes.numero_conta
    }

    add_transaction_data(base_params)
  end

  def add_transaction_data(params) do
    if trx_type =
         TransactionType.get(transaction_type: parse_transaction_type(params.forma_pagamento)) do
      fee_calc = Transactions.apply_fee(trx_type, amount: params.amount)

      %{
        amount: fee_calc.amount_with_fee,
        fee_in_cents: fee_calc.fee_in_cents,
        payment_type_id: trx_type.id,
        sender_account_id: params.account_id
      }
    end
  end

  def parse_transaction_type("P"), do: :pix
  def parse_transaction_type("C"), do: :credit_card
  def parse_transaction_type("D"), do: :debit_card
end
