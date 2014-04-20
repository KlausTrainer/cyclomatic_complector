defmodule CyclomaticComplector.Util do
  def make_tmp_dir! do
    {a, b, c} = :erlang.now
    timestamp = :lists.flatten(:io_lib.format("~p~p~p", [a, b, c]))
    dirname = "#{System.tmp_dir!}/#{timestamp}"
    File.mkdir!(dirname)
    dirname
  end
end
