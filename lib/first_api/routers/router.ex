defmodule FirstApi.Router do
  @moduledoc """
  Create, Read, Update, Delete REST API from Database Mysql
  """
  use Plug.Router

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)


  # get API Response Elixir
  get "/" do
    send_resp(conn, 200, "OK DI ELIXIR")
  end

  # Create Table Mahasiswa to DB Mysql
  get "/api/create_tablemahasiswa" do
    case MyXQL.query(
           :myxql,
           "CREATE TABLE mahasiswa (MhsId INT(11) AUTO_INCREMENT PRIMARY KEY, MahasiswaId VARCHAR(255), NomorMahasiswa INT(24), NamaMahasiswa VARCHAR(255), TanggalLahirSiswa DATE, TempatLahirSiswa TEXT)"
         ) do
      {:ok, _result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200,"Table Mahasiswa created")

      {:error, reason} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Get Api Mahasiswa
  get "/api/mahasiswa" do
    case MyXQL.query(:myxql, "SELECT * FROM mahasiswa") do
      {:ok, %{rows: result, columns: col}} ->
        formatted_result =
          Enum.map(result, fn row ->
            Enum.zip(col, row) |> Map.new()
          end)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(formatted_result))

      {:error, reason} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Get Mahasiswa By Id
  get "/api/mahasiswa/:id" do
    case MyXQL.query(:myxql, "SELECT * FROM mahasiswa WHERE MahasiswaId = '#{id}' LIMIT 1") do
      {:ok, %{rows: result, columns: col}} ->
        format_result =
          Enum.map(result, fn row ->
            Enum.zip(col, row) |> Map.new()
          end)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(format_result))

      {:ok, %{rows: []}} ->
        send_resp(conn, 404, "Issue not found")

      {:error, reason} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Create API Mahasiswa
  post "/api/create_mahasiswa" do
    case conn.body_params do
      %{
        "NomorMahasiswa" => no_mhs,
        "NamaMahasiswa" => nama_mhs,
        "TanggalLahirSiswa" => tgl_mhs,
        "TempatLahirSiswa" => alamat_mhs,
      } ->
        mhs_id = UUID.uuid4()
        current_date = Date.utc_today() # Mengambil tanggal hari ini dalam format UTC
        formatted_date = Date.to_string(current_date) # Mengonversi tanggal ke string
        query = "INSERT INTO mahasiswa (MahasiswaId, NomorMahasiswa, NamaMahasiswa, TanggalLahirSiswa, TempatLahirSiswa, CreatedAt) VALUES ('#{mhs_id}', #{no_mhs}, '#{nama_mhs}', '#{tgl_mhs}', '#{alamat_mhs}', '#{formatted_date}')"
        case MyXQL.query(:myxql, query) do
          {:ok, _} ->
            send_resp(conn, 201, Jason.encode!(%{message: "Mahasiswa created"}))

          {:error, _reason} ->
            send_resp(conn, 500, "Something went wrong")
        end
        {:error, _} ->
          send_resp(conn, 400, "Invalid request body")
    end
  end

  # Update API Mahasiswa
  put "/api/update_mahasiswa/:id" do
    id = conn.params["id"]

    case MyXQL.query(:myxql, "SELECT * FROM mahasiswa WHERE MahasiswaId = ? LIMIT 1", [id]) do
      {:ok, %{rows: [result]}} ->
        current_date = Date.utc_today() # Mengambil tanggal hari ini dalam format UTC
        formatted_date = Date.to_string(current_date) # Mengonversi tanggal ke string
        update_fields =
          conn.body_params
          |> Map.take(["NomorMahasiswa", "NamaMahasiswa", "TanggalLahirSiswa", "TempatLahirSiswa"])
          |> Map.put("UpdateAt", formatted_date)

        set_clause =
          Enum.map(update_fields, fn {column, value} ->
            "#{column} = '#{value}'"
          end)
          |> Enum.join(", ")

        query = "UPDATE mahasiswa SET #{set_clause} WHERE MahasiswaId = ?"

        case MyXQL.query(:myxql, query, [id]) do
          {:ok, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, "Mahasiswa Updated")

          {:error, reason} ->
            IO.inspect(reason, label: "MyXQL Error") # Cetak error message untuk debugging
            send_resp(conn, 500, "Something went wrong")

        end

      {:ok, %{rows: []}} ->
        send_resp(conn, 404, "Mahasiswa not found")

      {:ok, _result} ->
        send_resp(conn, 500, "Unexpected query result")

      {:error, reason} ->
        IO.inspect(reason, label: "MyXQL Error") # Cetak error message untuk debugging
        send_resp(conn, 500, "Something went wrong")
    end
  end

  # Delete API Mahasiswa
  delete "/api/delete_mahasiswa/:id" do
    id = conn.params["id"]

    case MyXQL.query(:myxql, "SELECT * FROM mahasiswa WHERE MahasiswaId = ? LIMIT 1", [id]) do
      {:ok, %{rows: [result]}} ->
        query = "DELETE FROM mahasiswa WHERE MahasiswaId = ?"

        case MyXQL.query(:myxql, query, [id]) do
          {:ok, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(%{message: "Mahasiswa Deleted"}))

          {:error, _reason} ->
            conn
            |> send_resp(500, "Something went wrong")
        end

      {:ok, %{rows: []}} ->
        conn
        |> send_resp(404, "Mahasiswa not found")

      _ ->
        conn
        |> send_resp(500, "Unexpected query result")
    end
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
