defmodule MoBank.FindAccount do
  @moduledoc """
  Operação responsável por buscar uma "conta" no banco de dados e retorná-la, caso a mesma exista.
  """

  alias MoBank.Entities.Account
  alias MoBank.Formatter

  @doc """
  Função que busca do banco e retorna uma "conta", caso exista.
  """
  @spec run(Keyword.t()) :: {:ok, map} | nil
  def run(parameters) do
    if account = Account.find(parameters) do
      format_to_external(account)
    end
  end

  defp format_to_external(account) do
    %{numero_conta: account.account_number, saldo: Formatter.to_float(account.balance)}
  end
end
