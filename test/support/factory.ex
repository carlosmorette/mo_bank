defmodule MoBank.Factory do
  alias MoBank.Repo
  alias MoBank.Entities.{TransactionType, Account, Transaction}

  def insert(:transaction_type, params) do
    TransactionType |> struct(params) |> Repo.insert!()
  end

  def insert(:account, params) do
    Account |> struct(params) |> Repo.insert!()
  end
end
