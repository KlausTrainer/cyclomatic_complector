defmodule CyclomaticComplector.Stat do
  alias CyclomaticComplector.Stat
  alias CyclomaticComplector.Metric

  defstruct language: nil, type: nil, name: nil, filename: nil, metrics: []

  def to_json(%Stat{language: language, type: type, name: name, filename: filename, metrics: metrics}) when is_binary(language) and is_binary(type) and is_binary(name) and is_binary(filename) and is_list(metrics) do
    "{\"language\":\"#{language}\",\"type\":\"#{type}\",\"name\":\"#{name}\",\"filename\":\"#{filename}\",\"metrics\":[#{Enum.join(Enum.map(metrics, &Metric.to_json/1), ",")}]}"
  end
end
