defmodule MoBank.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table(:transaction_types) do
      add :type, :string, null: false
      add :percentage_fee, :integer, null: false

      timestamps()
    end

    create unique_index(:transaction_types, [:type])

    create table(:accounts) do
      add :account_number, :string, null: false
      add :balance, :integer, null: false

      timestamps()
    end

    create unique_index(:accounts, [:account_number])

    create table(:transactions) do
      add :amount, :integer, null: false
      add :fee_in_cents, :integer, null: false
      add :status, :string, null: false

      add :sender_account_id, references(:accounts, column: :account_number, type: :string),
        null: false

      add :payment_type_id, references(:transaction_types), null: false

      timestamps()
    end
  end
end
