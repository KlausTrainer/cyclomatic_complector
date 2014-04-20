defmodule CyclomaticComplector.Commit do
  alias CyclomaticComplector.Commit

  defstruct hash: nil, timestamp: nil, author: nil

  def to_json(%Commit{hash: hash, timestamp: timestamp, author: author}) when is_binary(hash) and is_integer(timestamp) and is_binary(author) do
    "{\"hash\":\"#{hash}\",\"timestamp\":#{timestamp},\"author\":\"#{author}\"}"
  end
end
