defmodule MoBankWeb.AccountController do
  use MoBankWeb, :controller
  import MoBankWeb.HTTPStatusErrors, only: [bad_request: 2, not_found: 1]
  alias MoBank.{CreateAccount, FindAccount}

  def create(conn, params) do
    case CreateAccount.run(params) do
      {:ok, account_info} ->
        json(conn, account_info)

      {:error, error} ->
        bad_request(conn, error)
    end
  end

  def get(conn, %{"numero_conta" => account_number}) do
    if account_info = FindAccount.run(account_number: account_number) do
      json(conn, account_info)
    else
      not_found(conn)
    end
  end
end
