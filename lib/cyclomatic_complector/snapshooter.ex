defmodule CyclomaticComplector.Snapshooter do
  alias CyclomaticComplector.Util
  alias CyclomaticComplector.Git
  alias CyclomaticComplector.Commit
  alias CyclomaticComplector.Stat
  alias CyclomaticComplector.Snapshot
  alias CyclomaticComplector.Backend
  alias CyclomaticComplector.Language.Erlang

  def add_erlang_project(:github, project, ref) do
    :ok = Backend.Couchdb.create_db(project, ref)
    dir = Util.make_tmp_dir!
    :ok = Git.clone(dir, "https://github.com/#{project}.git")
    :ok = Git.checkout(dir, ref)
    {:ok, commits} = Git.log(dir)
    db = Backend.Couchdb.db(project, ref)
    Enum.each(commits, fn commit ->
      Backend.Couchdb.put_snapshot(db, create_erlang_snapshot(dir, commit))
    end)
  end

  # private

  defp create_erlang_snapshot(dir, %Commit{hash: hash} = commit) do
    :ok = Git.checkout(dir, hash)

    {:ok, files} = Git.show(dir, hash)

    erl_files = Enum.filter(files, fn file ->
      String.ends_with?(file, ".erl")
    end)

    stats = Enum.reduce(erl_files, [], fn rel_path, acc ->
      abs_path = "#{dir}/#{rel_path}"

      case File.exists?(abs_path) do
        :true ->
          {:ok, forms} = :epp.parse_file(
            :erlang.binary_to_list(abs_path),
            [:erlang.binary_to_list(dir)], [])

          stat = %Stat{
            language: "erlang",
            type: "module",
            name: Path.basename(rel_path, ".erl"),
            filename: rel_path,
            metrics: Erlang.Metrics.mc_cabe(forms)
          }

          [stat | acc]
        :false ->
          acc
      end
    end)

    %Snapshot{commit: commit, stats: stats}
  end
end
