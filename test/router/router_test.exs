defmodule FirstApiTest.RouterTest do
  use ExUnit.Case, async: true

    # Sebelum melakukan tes, Anda mungkin perlu menyiapkan koneksi (connection) palsu.
    setup do
      {:ok, conn} = Plug.Test.init_test_env([])
      {:ok, conn: conn}
    end

    test "GET / returns 200 and 'OK DI ELIXIR'" do
      conn = get(conn, "/")
      assert conn.status == 200
      assert conn.resp_body == "OK DI ELIXIR"
    end

end
