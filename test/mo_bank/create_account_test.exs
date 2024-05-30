defmodule MoBank.ManageAccountsTest do
  use ExUnit.Case, async: true

  alias MoBank.CreateAccount

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoBank.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MoBank.Repo, {:shared, self()})
  end

  describe "run/1" do
    test "it should create an account and return his fields" do
      assert {:ok, %{saldo: 1.0, numero_conta: "87"}} =
               CreateAccount.run(%{saldo: 1.00, numero_conta: "87"})
    end

    test "it should return an error when `saldo` is `integer`" do
      assert {:error, :invalid_balance} = CreateAccount.run(%{saldo: 1, numero_conta: "900"})
    end

    test "it should return an error when `saldo` is missing" do
      assert {:error, :invalid_balance} = CreateAccount.run(%{numero_conta: "900"})
    end

    test "it should return an error when `numero_conta` is missing" do
      assert {:error, %{account_number: ["can't be blank"]}} = CreateAccount.run(%{saldo: 99.19})
    end
  end
end
