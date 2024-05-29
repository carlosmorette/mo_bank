defmodule MoBank.Entities.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias MoBank.Repo

  schema "accounts" do
    field :balance, :integer

    timestamps()
  end

  def create_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :id])
    |> validate_required([:balance, :id])
  end

  def create(data) do
    %__MODULE__{}
    |> create_changeset(data)
    |> Repo.insert()
  end
end
