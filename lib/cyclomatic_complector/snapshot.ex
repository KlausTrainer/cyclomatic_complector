defmodule CyclomaticComplector.Snapshot do
  alias CyclomaticComplector.Snapshot
  alias CyclomaticComplector.Commit
  alias CyclomaticComplector.Stat

  defstruct commit: %Commit{}, stats: []

  def to_json(%Snapshot{commit: %Commit{} = commit, stats: stats}) do
    "{\"commit\":#{Commit.to_json(commit)},\"stats\":[#{Enum.join(Enum.map(stats, &Stat.to_json/1), ",")}]}"
  end
end
