defmodule CyclomaticComplector.Backend.Couchdb do
  alias CyclomaticComplector.Snapshot
  alias CyclomaticComplector.Commit

  def db(project, branch) do
    URI.encode("#{project}/#{branch}")
  end

  def create_db(project, branch) do
    url = db_url(db(project, branch))
    case httpc_put_request(url, "") do
      {:ok, {201, _}} -> :ok
      {:ok, {412, _}} -> :already_exists
      {:error, reason} -> {:error, reason}
    end
  end

  def put_snapshot(db, %Snapshot{commit: %Commit{hash: hash}} = snapshot) do
    url = "#{db_url(db)}/#{hash}"
    case httpc_put_request(url, Snapshot.to_json(snapshot)) do
      {:ok, {201, _}} -> :ok
      {:ok, {409, _}} -> :conflict
      {:error, reason} -> {:error, reason}
    end
  end

  # private

  defp httpc_put_request(url, body) do
    request = {:erlang.binary_to_list(url), [], 'application/json', body}
    options = [body_format: :binary, full_result: false]
    :httpc.request(:put, request, [], options)
  end

  defp db_url(db) do
    {:ok, host} = :application.get_env(:cyclomatic_complector, :couchdb_host)
    {:ok, port} = :application.get_env(:cyclomatic_complector, :couchdb_port)
    case :application.get_env(:cyclomatic_complector, :couchdb_credentials) do
      :undefined ->
        "http://#{host}:#{port}/#{db}"
      {:ok, {username, password}} ->
        "http://#{username}:#{password}@#{host}:#{port}/#{db}"
    end
  end
end
