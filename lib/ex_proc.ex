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

  #   iex(1)> ExProc.send_calc(10,20)
  # {:sum, 10, 20}

  def send_calc(type, number_1, number_2) do
    send(self(), {type, number_1, number_2})
  end

  #   iex(2)> ExProc.receive_calc
  # 30
  def receive_calc do
    receive do
      {:sum, number_1, number_2} -> number_1 + number_2
      {:div, number_1, number_2} -> number_1 / number_2
      {:mul, number_1, number_2} -> number_1 * number_2
      {:sub, number_1, number_2} -> number_1 - number_2
    after
      5000 -> IO.puts("Timeout !!")
    end
  end

  # iex(7)> ExProc.send_calc :sum, 10, 20
  # {:sum, 10, 20}
  # iex(8)> ExProc.receive_calc
  # 30
  # iex(9)> ExProc.send_calc :sub, 100, 20
  # {:sub, 100, 20}
  # iex(10)> ExProc.receive_calc
  # 80
  # iex(11)> ExProc.send_calc :mul, 10, 20
  # {:mul, 10, 20}
  # iex(12)> ExProc.receive_calc
  # 200
  # iex(13)> ExProc.send_calc :div, 20, 10
  # {:div, 20, 10}
  # iex(14)> ExProc.receive_calc
  # 2.0
  # iex(15)> ExProc.send_calc :divv, 20, 10
  # {:divv, 20, 10}
  # iex(16)> ExProc.receive_calc
  # Timeout !!
  # :ok

  # iex(23)> account_id = ExProc.create_account
  # #PID<0.181.0>
  # iex(24)> send account_id, {:add, 10}
  # old value 0  new value 10
  # {:add, 10}
  # iex(25)> send account_id, {:add, 10}
  # old value 10  new value 20
  # {:add, 10}
  # iex(26)> send account_id, {:withraw, 10}
  # old value 20  new value 10
  # {:withraw, 10}
  def create_account, do: spawn(__MODULE__, :state_receive, [0])

  def state_receive(money) do
    receive do
      {:add, value} ->
        new_value = money + value
        IO.puts("old value #{money}  new value #{new_value}")
        state_receive(new_value)

      {:withraw, value} ->
        new_value = money - value
        IO.puts("old value #{money}  new value #{new_value}")
        state_receive(new_value)
    end
  end

  def create_connection_db, do: spawn(__MODULE__, :execute_connection, [:rand.uniform(3_000)])

  def execute_connection(conn_db) do
    receive do
      {:execute_query, from, query} ->
        result = execute_query(conn_db, query)
        send(from, {:print_result, result})
    end

    # Calling same method again to keep the process alive
    execute_connection(conn_db)
  end

  defp execute_query(conn_db, query) do
    :timer.sleep(2_000)
    "Connection #{conn_db} executed: #{query}"
  end

  def print_result do
    receive do
      {:print_result, result} -> result
    after
      5_000 -> "Something went wrong."
    end
  end

  def call_query(server, query) do
    send(server, {:execute_query, self(), query})
  end

  #   iex(29)> conn = ExProc.create_connection_db
  # #PID<0.189.0>
  # iex(30)> ExProc.call_query conn, "Select * from products"
  # {:execute_query, #PID<0.134.0>, "Select * from products"}
  # iex(31)> ExProc.print_result
  # "Connection 2170 executed: Select * from products"
  # iex(32)> ExProc.call_query conn, "Select * from products as p"
  # {:execute_query, #PID<0.134.0>, "Select * from products as p"}
  # iex(33)> ExProc.print_result
  # "Connection 2170 executed: Select * from products as p"
  # iex(34)> 1..10 |> Enum.map(&ExProc.call_query(conn, "select #{&1}"))
  # [  NOTICE THE SAME PID
  #   {:execute_query, #PID<0.134.0>, "select 1"},
  #   {:execute_query, #PID<0.134.0>, "select 2"},
  #   {:execute_query, #PID<0.134.0>, "select 3"},
  #   {:execute_query, #PID<0.134.0>, "select 4"},
  #   {:execute_query, #PID<0.134.0>, "select 5"},
  #   {:execute_query, #PID<0.134.0>, "select 6"},
  #   {:execute_query, #PID<0.134.0>, "select 7"},
  #   {:execute_query, #PID<0.134.0>, "select 8"},
  #   {:execute_query, #PID<0.134.0>, "select 9"},
  #   {:execute_query, #PID<0.134.0>, "select 10"}
  # ]
  # iex(35)> 1..10 |> Enum.map( fn _ -> ExProc.print_result end)
  # ["Connection 2170 executed: select 1", "Connection 2170 executed: select 2",
  #  "Connection 2170 executed: select 3", "Connection 2170 executed: select 4",
  #  "Connection 2170 executed: select 5", "Connection 2170 executed: select 6",
  #  "Connection 2170 executed: select 7", "Connection 2170 executed: select 8",
  #  "Connection 2170 executed: select 9", "Connection 2170 executed: select 10"]
  # NOTICE THE SAME PID ABOVE

  #  iex(37)> 1..10 |> Enum.map(&ExProc.call_query(ExProc.create_connection_db, "select #{&1}"))
  # [ NOTICE THE SAME PID
  #   {:execute_query, #PID<0.134.0>, "select 1"},
  #   {:execute_query, #PID<0.134.0>, "select 2"},
  #   {:execute_query, #PID<0.134.0>, "select 3"},
  #   {:execute_query, #PID<0.134.0>, "select 4"},
  #   {:execute_query, #PID<0.134.0>, "select 5"},
  #   {:execute_query, #PID<0.134.0>, "select 6"},
  #   {:execute_query, #PID<0.134.0>, "select 7"},
  #   {:execute_query, #PID<0.134.0>, "select 8"},
  #   {:execute_query, #PID<0.134.0>, "select 9"},
  #   {:execute_query, #PID<0.134.0>, "select 10"}
  # ]
  # iex(38)> 1..10 |> Enum.map( fn _ -> ExProc.print_result end)
  # ["Connection 387 executed: select 1", "Connection 86 executed: select 2",
  #  "Connection 2199 executed: select 3", "Connection 616 executed: select 4",
  #  "Connection 2965 executed: select 5", "Connection 2799 executed: select 6",
  #  "Connection 1542 executed: select 7", "Connection 2746 executed: select 8",
  #  "Connection 414 executed: select 9", "Connection 2899 executed: select 10"]
  # NOTICE THE DIFFERENT PID ABOVE
end
