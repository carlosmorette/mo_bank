defmodule MoBank.FindAccount do
  alias MoBank.Entities.Account
  alias MoBank.Formatter

  def run(parameters) do
    if account = Account.find(parameters) do
      format_to_external(account)
    end
  end

  defp format_to_external(account) do
    %{
      numero_conta: account.account_number,
      saldo: Formatter.to_float(account.balance)
    }
  end
end
