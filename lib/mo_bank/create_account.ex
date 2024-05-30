defmodule MoBank.CreateAccount do
  @moduledoc """
  Operação dentro do sistema responsável por criar "contas".
  """

  alias MoBank.Entities.Account
  alias MoBank.Formatter

  @type external_return :: %{
          numero_conta: String.t(),
          saldo: float
        }

  @doc """
  Função responsável por criar uma "conta" dentro do sistema. A conta é uma entidade que pode
  simplesmente realizar "transações" que por sua vez, possui um saldo próprio.
  """
  @spec run(map) :: {:ok, external_return} | {:error, atom}
  def run(external_params) do
    with {:ok, formatted_params} <- format_to_database(external_params) do
      case Account.create(formatted_params) do
        {:ok, %Account{} = account} ->
          {:ok, format_to_external(account)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, Ecto.Changeset.traverse_errors(changeset, fn {msg, _otps} -> msg end)}
      end
    end
  end

  defp format_to_database(data) do
    if is_float(data[:saldo]) do
      {:ok,
       %{
         account_number: data[:numero_conta],
         balance: Formatter.to_cents(data[:saldo])
       }}
    else
      {:error, :invalid_balance}
    end
  end

  defp format_to_external(%Account{} = acc) do
    %{
      numero_conta: acc.account_number,
      saldo: Formatter.to_float(acc.balance)
    }
  end
end
