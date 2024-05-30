defmodule MoBankWeb.AccountControllerTest do
  use MoBankWeb.ConnCase
  import MoBank.Factory

  alias MoBank.Entities.Account

  describe "POST /conta - create an account" do
    test "it should create an account successfully", %{conn: conn} do
      account_number = "6678"

      result =
        conn
        |> post("/conta", %{numero_conta: account_number, saldo: 56.78})
        |> json_response(:ok)

      assert %{"numero_conta" => ^account_number, "saldo" => 56.78} = result

      assert %Account{account_number: ^account_number, balance: 5678} =
               Account.find(account_number: account_number)
    end

    test "it should return an error when parameter `saldo` is missing", %{conn: conn} do
      result =
        conn
        |> post("/conta", %{numero_conta: "3333"})
        |> json_response(:bad_request)

      assert %{"error" => "invalid_balance"} = result
    end

    test "it should return an error when parameter type `saldo`is incorrect", %{conn: conn} do
      result =
        conn
        |> post("/conta", %{numero_conta: "3333", saldo: 1})
        |> json_response(:bad_request)

      assert %{"error" => "invalid_balance"} = result
    end

    test "it should return an error when parameter `numero_conta` is missing", %{conn: conn} do
      result =
        conn
        |> post("/conta", %{saldo: 1.0})
        |> json_response(:bad_request)

      assert %{"error" => %{"account_number" => ["can't be blank"]}} = result
    end
  end

  describe "GET /conta - get an account" do
    test "it should return an existing account", %{conn: conn} do
      account = insert(:account, %{balance: 0, account_number: "6345"})

      result =
        conn
        |> get("/conta", numero_conta: account.account_number)
        |> json_response(:ok)

      assert %{"numero_conta" => "6345", "saldo" => 0.0} = result
    end

    test "it should not found when account doesn't exists", %{conn: conn} do
      assert conn |> get("/conta", numero_conta: "111111") |> json_response(:not_found)
    end
  end
end
