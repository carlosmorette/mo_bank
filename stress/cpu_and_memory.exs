defmodule LoadTest do
  @url "http://192.168.184.2:30080/api/stress"
  @total 1000

  def run do
    :inets.start()

    1..@total
    |> Task.async_stream(
      fn i -> request(i) end,
      max_concurrency: @total,
      timeout: 20_000
    )
    |> Stream.run()
  end

  defp request(i) do
    Task.async(fn -> :httpc.request(:get, {@url <> "/cpu", []}, [], []) end)
    Task.async(fn -> :httpc.request(:get, {@url <> "/ram", []}, [], []) end)

    IO.puts("#{i}")
  end
end

LoadTest.run()
