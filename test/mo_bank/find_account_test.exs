defmodule MoBank.FindAccountTest do
  use ExUnit.Case, async: true
  import MoBank.Factory
  alias MoBank.FindAccount

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoBank.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MoBank.Repo, {:shared, self()})
  end

  describe "run" do
    test "it should search, find and return an account" do
      account = insert(:account, %{account_number: "3391", balance: 354})

      assert %{numero_conta: "3391", saldo: 3.54} =
               FindAccount.run(account_number: account.account_number)
    end

    test "it should return `nil` when account doens't exists" do
      assert is_nil(FindAccount.run(account_number: "8888"))
    end
  end
end
