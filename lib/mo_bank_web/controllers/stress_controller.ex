defmodule MoBankWeb.StressController do
  use MoBankWeb, :controller

   def cpu(conn, params) do
    factor = String.to_integer(params["factor"] || "1")

    Enum.each(1..factor, fn _ ->
      Enum.reduce(1..20_000_000, 0, fn i, acc ->
        :math.sqrt(i) + acc
      end)
    end)

    json(conn, %{status: "cpu stressed", factor: factor})
  end

  def ram(conn, params) do
    mb = String.to_integer(params["mb"] || "50")

    data =
      Enum.map(1..mb, fn _ ->
        :crypto.strong_rand_bytes(1_000_000)
      end)

    # impede GC imediato
    Process.put(:leak, data)

    json(conn, %{status: "ram stressed", mb: mb})
  end
end
