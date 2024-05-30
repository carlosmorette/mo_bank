defmodule MoBank.PerformTransactionTest do
  use ExUnit.Case
  import MoBank.Factory
  alias MoBank.PerformTransaction

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoBank.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MoBank.Repo, {:shared, self()})

    insert(:transaction_type, %{type: :credit_card, percentage_fee: 5})
    insert(:transaction_type, %{type: :debit_card, percentage_fee: 3})
    insert(:transaction_type, %{type: :pix, percentage_fee: 0})
    account = insert(:account, %{account_number: "34431", balance: 1000})

    {:ok, %{account: account}}
  end

  describe "run/1" do
    test "it should create an `credit_card` transaction and decrease `Account` balance", %{
      account: account
    } do
      account_number = account.account_number

      assert {:ok, %{numero_conta: ^account_number, saldo: 4.75}} =
               PerformTransaction.run(%{
                 numero_conta: account.account_number,
                 forma_pagamento: "C",
                 valor: 5.00
               })
    end

    test "it should create an `debit_card` transaction and decrease `Account` balance", %{
      account: account
    } do
      account_number = account.account_number

      assert {:ok, %{numero_conta: ^account_number, saldo: 4.85}} =
               PerformTransaction.run(%{
                 numero_conta: account.account_number,
                 forma_pagamento: "D",
                 valor: 5.00
               })
    end

    test "it should create an `pix` transaction and decrease `Account` balance", %{
      account: account
    } do
      account_number = account.account_number

      assert {:ok, %{numero_conta: ^account_number, saldo: 5.00}} =
               PerformTransaction.run(%{
                 numero_conta: account.account_number,
                 forma_pagamento: "P",
                 valor: 5.00
               })
    end

    test "it should simulate a race condition scenario when 2 request will not complete", %{
      account: account
    } do
      trx_params = %{
        numero_conta: account.account_number,
        forma_pagamento: "P",
        valor: 10.00
      }

      ## simulating a real scenario
      first_task = Task.async(fn -> PerformTransaction.run(trx_params) end)
      :timer.sleep(1_000)
      second_task = Task.async(fn -> PerformTransaction.run(trx_params) end)

      account_number = account.account_number

      assert {:ok, %{numero_conta: ^account_number, saldo: 0.0}} = Task.await(first_task)
      assert {:error, %{validate_account: :insufficient_balance}} = Task.await(second_task)
    end
  end
end
