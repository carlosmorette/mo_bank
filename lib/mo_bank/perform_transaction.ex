defmodule MoBank.PerformTransaction do
  use Params

  alias MoBank.{Repo, Formatter, Transactions}
  alias MoBank.Entities.{Account, Transaction}

  defparams(
    perform_transaction_params(%{
      forma_pagamento!: :string,
      numero_conta!: :integer,
      valor!: :float
    })
  )

  def run(external_params) do
    with {:ok, params} <- validate_and_format_external_params(external_params) do
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :account,
        Account.query_find_for_update(account_number: params.sender_account_id)
      )
      |> Ecto.Multi.run(:validate_account, fn
        _repo, %{account: nil} ->
          {:error, :unknown_account}

        _repo, %{account: account} ->
          check_has_sufficient_balance(account, params.amount)
      end)
      |> Ecto.Multi.update(:decrease_balance, fn %{account: account} ->
        Account.decrease_balance_changeset(account, amount: params.amount)
      end)
      |> Ecto.Multi.insert(:transaction, Transaction.create_changeset(params))
      |> Repo.transaction()
      |> format_to_return()
    end
  end

  def format_to_return({:ok, %{decrease_balance: account}}) do
    {:ok,
     %{
       numero_conta: account.account_number,
       saldo: Formatter.to_float(account.balance)
     }}
  end

  def format_to_return({:error, step, error, _state}), do: {:error, %{step => error}}

  def check_has_sufficient_balance(%Account{} = account, transaction_amount)
      when is_integer(transaction_amount) do
    if account.balance >= transaction_amount,
      do: {:ok, account},
      else: {:error, :insufficient_balance}
  end

  def validate_and_format_external_params(data) do
    with %Ecto.Changeset{valid?: true} = changeset <- perform_transaction_params(data),
         base_params <- base_params(changeset),
         {:ok, transaction_type} <- Transactions.find_trx_type(base_params.transaction_type) do
      {:ok, format_transaction_parameters(base_params, transaction_type)}
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)}

      {:error, error} ->
        {:error, error}
    end
  end

  def base_params(%Ecto.Changeset{} = changeset) do
    %{
      transaction_type: changeset.changes.forma_pagamento,
      account_number: changeset.changes.numero_conta,
      amount: changeset.changes.valor
    }
  end

  def format_transaction_parameters(base_params, trx_type) do
    fee_calc = Transactions.apply_fee(trx_type, amount: base_params.amount)

    %{
      fee_in_cents: fee_calc.fee_in_cents,
      amount: fee_calc.amount_with_fee,
      payment_type_id: trx_type.id,
      sender_account_id: to_string(base_params.account_number)
    }
  end
end
