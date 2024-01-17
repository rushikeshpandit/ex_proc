defmodule ExProc do
  #  Every time we invoke the process, we got new process id
  #   iex(12)> ExProc.my_first_spawn "Rushikesh"
  # Hello Rushikesh
  # #PID<0.153.0>
  # iex(13)> ExProc.my_first_spawn "Rushikesh"
  # Hello Rushikesh
  # #PID<0.154.0>
  # iex(14)> ExProc.my_first_spawn "Rushikesh"
  # Hello Rushikesh
  # #PID<0.155.0>
  # iex(15)> ExProc.my_first_spawn "Rushikesh"
  # Hello Rushikesh
  # #PID<0.156.0>

  # To check process status
  # iex(16)> pid = pid("0.156.0")
  # #PID<0.156.0>
  # iex(17)> Process.alive? pid
  # false

  def my_first_spawn(name), do: spawn(__MODULE__, :hi, [name])

  def hi(name), do: IO.puts("Hello #{name}")

  #   ExProc.query 4
  # [#PID<0.207.0>, #PID<0.208.0>, #PID<0.209.0>, #PID<0.210.0>]
  # 1 executed
  # 2 executed
  # 3 executed
  # 4 executed
  def query(n) do
    execute = fn q ->
      # This is how we use the timer, time is given in seconds i.e. 2 seconds
      :timer.sleep(2_000)
      "#{q} executed"
    end

    # This line will print the process id in async manner
    async = &spawn(fn -> IO.puts(execute.(&1)) end)
    1..n |> Enum.map(&async.(&1))
  end
end
