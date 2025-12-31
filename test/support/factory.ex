defmodule MoBank.Factory do
  @moduledoc """
  Módulo de fábrica para geração de dados de teste.

  Fornece funções auxiliares para criar registros no banco de dados
  durante a execução dos testes.
  """
  alias MoBank.Entities.{Account, Transaction, TransactionType}
  alias MoBank.Repo

  def insert(:transaction_type, params) do
    TransactionType |> struct(params) |> Repo.insert!()
  end

  def insert(:account, params) do
    Account |> struct(params) |> Repo.insert!()
  end
end
