defmodule MoBankWeb.TransactionControllerTest do
  use MoBankWeb.ConnCase
  import MoBank.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoBank.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MoBank.Repo, {:shared, self()})

    insert(:transaction_type, %{type: :credit_card, percentage_fee: 5})
    insert(:transaction_type, %{type: :debit_card, percentage_fee: 3})
    insert(:transaction_type, %{type: :pix, percentage_fee: 0})
    account = insert(:account, %{account_number: "34431", balance: 1000})

    {:ok, %{account: account}}
  end

  describe "POST /transacao - create a transaction" do
    test "it should create a transaction successfully with `Pix`", %{conn: conn, account: account} do
      account_number = account.account_number

      result =
        conn
        |> post("/transacao", %{
          numero_conta: account.account_number,
          forma_pagamento: "P",
          valor: 1.00
        })
        |> json_response(:ok)

      assert %{"numero_conta" => ^account_number, "saldo" => 9.00} = result
    end

    test "it should create a transaction successfully with `Debit Card`", %{
      conn: conn,
      account: account
    } do
      account_number = account.account_number

      result =
        conn
        |> post("/transacao", %{
          numero_conta: account.account_number,
          forma_pagamento: "D",
          valor: 1.00000
        })
        |> json_response(:ok)

      assert %{"numero_conta" => ^account_number, "saldo" => 8.97} = result
    end

    test "it should create a transaction successfully with `Credit Card`", %{
      conn: conn,
      account: account
    } do
      account_number = account.account_number

      result =
        conn
        |> post("/transacao", %{
          numero_conta: account.account_number,
          forma_pagamento: "C",
          valor: 1.00
        })
        |> json_response(:ok)

      assert %{"numero_conta" => ^account_number, "saldo" => 8.95} = result
    end

    test "it should return invalid payment method", %{conn: conn, account: account} do
      body = %{
        numero_conta: account.account_number,
        forma_pagamento: "KLJ",
        valor: 1.00
      }

      assert conn |> post("/transacao", body) |> json_response(:bad_request)
    end

    test "it should return account not found", %{conn: conn} do
      body = %{
        numero_conta: "999999",
        forma_pagamento: "D",
        valor: 1.00
      }

      assert conn |> post("/transacao", body) |> json_response(:not_found)
    end

    test "it should return insufficient balance", %{conn: conn, account: account} do
      body = %{
        numero_conta: account.account_number,
        forma_pagamento: "D",
        valor: 99.00
      }

      assert conn |> post("/transacao", body) |> json_response(:bad_request)
    end
  end
end
