defmodule CyclomaticComplector.Metric do
  alias CyclomaticComplector.Metric

  defstruct function: nil, name: nil, value: nil

  def to_json(%Metric{function: function, name: name, value: value}) when is_binary(function) and is_binary(name) and is_integer(value) do
    "{\"function\":\"#{function}\",\"name\":\"#{name}\",\"value\":#{value}}"
  end
end
