defmodule LoadTest do
  @url 'http://192.168.184.2:30080/api/health/health'
  @total 1000
  
  def run do
    :inets.start()

    1..@total
    |> Task.async_stream(
      fn i -> request(i) end,
      max_concurrency: @total,
      timeout: 10_000
    )
    |> Stream.run()
  end

  defp request(i) do
    case :httpc.request(:get, {@url, []}, [], []) do
      {:ok, {{_, status, _}, _headers, _body}} ->
        IO.puts("[#{i}] status=#{status}")

      {:error, reason} ->
        IO.puts("[#{i}] error=#{inspect(reason)}")
    end
  end
end

LoadTest.run()
