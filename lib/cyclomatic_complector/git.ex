defmodule CyclomaticComplector.Git do
  alias CyclomaticComplector.Commit

  # get a list of all commits
  def log(dir) do
    command = "git log --format=\"%H,%at,%aN\" --no-merges"
    port = open_port(command, [{:cd, dir}, {:line, 65535}])
    git_log_result(port)
  end

  def checkout(dir, ref) do
    command = "git checkout -q #{ref}"
    port = open_port(command, [{:cd, dir}])
    git_checkout_result(port)
  end

  def clone(dir, repository) do
    command = "git clone -q #{repository} #{dir}"
    port = open_port(command, [{:cd, dir}])
    git_clone_result(port)
  end

  # get a list of all changed files
  def show(dir, ref) do
    command = "git show --name-only --format=oneline #{ref} | tail -n +2"
    port = open_port(command, [{:cd, dir}, {:line, 2048}])
    git_show_result(port)
  end

  # private functions

  defp open_port(command, options) do
    port_options = options ++ [:stream, :binary, :exit_status]
    :erlang.open_port({:spawn, command}, port_options)
  end

  defp git_log_result(port) do
    git_log_result(port, [])
  end

  defp git_log_result(port, acc) do
    receive do
      {^port, {:exit_status, 0}} ->
        {:ok, acc}
      {^port, {:exit_status, code}} ->
        {:error, code}
      {^port, {:data, {:eol, line}}} ->
        regex = ~r"^([0-9a-f]+),([0-9]+),(.+)$"
        [_, hash, timestamp, author] = Regex.run(regex, line)
        commit = %Commit{
          hash: hash,
          timestamp: binary_to_integer(timestamp),
          author: author
        }
        git_log_result(port, [commit|acc])
      {^port, msg} ->
        log_unexpected_message(msg)
        git_log_result(port, acc)
    end
  end

  defp git_checkout_result(port) do
    exit_status(port)
  end

  defp git_clone_result(port) do
    exit_status(port)
  end

  defp git_show_result(port) do
    git_show_result(port, [])
  end

  defp git_show_result(port, acc) do
    receive do
      {^port, {:exit_status, 0}} ->
        {:ok, acc}
      {^port, {:exit_status, code}} ->
        {:error, code}
      {^port, {:data, {:eol, line}}} ->
        git_show_result(port, [line|acc])
      {^port, msg} ->
        log_unexpected_message(msg)
        git_show_result(port, acc)
    end
  end

  defp exit_status(port) do
    receive do
      {^port, {:exit_status, 0}} ->
        :ok
      {^port, {:exit_status, code}} ->
        {:error, code}
      {^port, msg} ->
        log_unexpected_message(msg)
        exit_status(port)
    end
  end

  defp log_unexpected_message(msg) do
    :error_logger.error_msg('received unexpected message: ~p~n', [msg])
  end
end
