defmodule MoBank.TransactionsTest do
  use ExUnit.Case
  import MoBank.Factory

  alias Ecto.Adapters.SQL.Sandbox

  alias MoBank.Transactions
  alias MoBank.Entities.TransactionType
  alias MoBank.Repo

  setup do
    :ok = Sandbox.checkout(Repo)
    Sandbox.mode(Repo, {:shared, self()})

    :ok
  end

  describe "apply_fee/2" do
    test "it should apply 0% of fee on transaction amount for Pix transaction" do
      trx_type = insert(:transaction_type, %{type: :pix, percentage_fee: 0})

      assert %{amount_with_fee: 100, fee_in_cents: 0} =
               Transactions.apply_fee(trx_type, amount: 1.0)
    end

    test "it should apply 3% of fee on transaction amount for Debit card transaction" do
      trx_type = insert(:transaction_type, %{type: :debit_card, percentage_fee: 3})

      assert %{amount_with_fee: 103, fee_in_cents: 3} =
               Transactions.apply_fee(trx_type, amount: 1.0)

      assert %{amount_with_fee: 1030, fee_in_cents: 30} =
               Transactions.apply_fee(trx_type, amount: 10.00)
    end

    test "it should apply 5% fee on transaction amount for Debit card transaction" do
      trx_type = insert(:transaction_type, %{type: :credit_card, percentage_fee: 5})

      assert %{amount_with_fee: 21_000, fee_in_cents: 10_00} =
               Transactions.apply_fee(trx_type, amount: 200.00)

      assert %{amount_with_fee: 1050, fee_in_cents: 50} =
               Transactions.apply_fee(trx_type, amount: 10.00)
    end
  end

  describe "find_trx_type" do
    test "it should search and find 3 types of transaction_type" do
      insert(:transaction_type, %{type: :credit_card, percentage_fee: 5})
      insert(:transaction_type, %{type: :debit_card, percentage_fee: 3})
      insert(:transaction_type, %{type: :pix, percentage_fee: 0})

      assert {:ok, %TransactionType{type: :credit_card, percentage_fee: 5}} =
               Transactions.find_trx_type("C")

      assert {:ok, %TransactionType{type: :debit_card, percentage_fee: 3}} =
               Transactions.find_trx_type("D")

      assert {:ok, %TransactionType{type: :pix, percentage_fee: 0}} =
               Transactions.find_trx_type("P")
    end

    test "it should return an error when transaction type doesn't exists" do
      assert {:error, :unknown_transaction_type} = Transactions.find_trx_type("ABCD")
    end
  end
end
