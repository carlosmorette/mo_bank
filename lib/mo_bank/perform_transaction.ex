defmodule MoBank.PerformTransaction do
  @moduledoc """
  Operação dentro do sistema responsável por realizar "transações". No sistema, "transação" significa:
  - Diminuir o saldo da conta participante
  - Registrar a "movimentação"
  """

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

  @type external_return :: %{
          numero_conta: String.t(),
          saldo: float
        }

  @doc """
  Função responsável por realizar uma "transação" dentro do sistema. Para isso, é necessário
  informar:
  - conta desejada
  - valor desejado
  - tipo da operação, seja Pix, cartão de débito ou cartão de crédito

  Tirando a parte de validar os parâmetros, toda a operação acontece dentro de uma "transação" no banco
  com com "lock pessimista" garantindo que não acontecerá problemas de "race condition" com o saldo da
  conta participante da transação.
  """
  @spec run(map) :: {:ok, external_return} | {:error, atom}
  def run(external_params) do
    with {:ok, params} <- validate_and_format_external_params(external_params) do
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :account,
        Account.query_find_for_update(account_number: params.sender_account_id)
      )
      |> Ecto.Multi.run(:validate_account, fn
        _repo, %{account: nil} ->
          {:error, :account_not_found}

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

  defp check_has_sufficient_balance(%Account{} = account, transaction_amount)
       when is_integer(transaction_amount) do
    if account.balance >= transaction_amount,
      do: {:ok, account},
      else: {:error, :insufficient_balance}
  end

  defp validate_and_format_external_params(data) do
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

  defp base_params(%Ecto.Changeset{} = changeset) do
    %{
      transaction_type: changeset.changes.forma_pagamento,
      account_number: changeset.changes.numero_conta,
      amount: changeset.changes.valor
    }
  end

  defp format_transaction_parameters(base_params, trx_type) do
    fee_calc = Transactions.apply_fee(trx_type, amount: base_params.amount)

    %{
      fee_in_cents: fee_calc.fee_in_cents,
      amount: fee_calc.amount_with_fee,
      payment_type_id: trx_type.id,
      sender_account_id: to_string(base_params.account_number)
    }
  end

  defp format_to_return({:ok, %{decrease_balance: account}}) do
    {:ok,
     %{
       numero_conta: account.account_number,
       saldo: Formatter.to_float(account.balance)
     }}
  end

  defp format_to_return({:error, _step, error, _state}), do: {:error, error}
end
