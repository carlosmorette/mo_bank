# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MoBank.Repo.insert!(%MoBank.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MoBank.Entities.{Account, TransactionType, Transaction}

{:ok, account} = Account.create(%{balance: 5600, account_number: "1"})
{:ok, transaction_type} = TransactionType.create(type: :pix, percentage_fee: 0)

transaction =
  Transaction.create_changeset(%{
    amount: 5,
    fee_in_cents: 0,
    sender_account_id: account.account_number,
    payment_type_id: transaction_type.id
  })
  |> MoBank.Repo.insert!()

IO.puts("""
Created account with number: #{account.account_number} and with R$ #{MoBank.Formatter.to_float(account.balance)}
Transaction Type with ID: #{transaction_type.id}
Transaction with ID: #{transaction.id} and amount: #{transaction.amount}
""")
