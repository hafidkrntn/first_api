defmodule FirstApiTest.RouterTest do
  use ExUnit.Case, async: true

  use Plug.Test

  @opts FirstApi.Router.init([])

  test "return ok" do
    build_conn = conn(:get, "/")
    conn = FirstApi.Router.call(build_conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK DI ELIXIR"
  end

  test "creates Mahasiswa table on successful query" do
    conn = conn()
    {:ok, _conn} = MyApp.Router.api_create_tablemahasiswa(conn)

    assert %{"status" => "Table Mahasiswa created"} = json_response(conn, 200)
  end

  test "returns 500 on query error" do
    conn = conn()
    {:error, _conn} = MyApp.Router.api_create_tablemahasiswa(conn)

    assert %{"status" => "Something went wrong"} = json_response(conn, 500)
  end

  defp json_response(conn, status) do
    conn
    |> get_resp(status)
    |> Poison.decode!()
  end
end
