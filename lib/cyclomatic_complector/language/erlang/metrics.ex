defmodule CyclomaticComplector.Language.Erlang.Metrics do
  alias CyclomaticComplector.Metric

  def mc_cabe(forms) do
    functions = for {:function, _, name, arity, body} <- forms, do: {name, arity, body}
    Enum.map(
      functions,
      fn {name, arity, body} ->
        %Metric{
          function: "#{name}/#{arity}",
          name: "mc_cabe",
          value: mc_cabe(body, 0)
        }
      end)
  end

  # private functions

  defp mc_cabe([], acc), do: acc

  defp mc_cabe([{:clause, _, _, _, body}|t], acc) do
    mc_cabe(t, mc_cabe(body, acc + 1))
  end

  defp mc_cabe([{:case, _, _, clauses}|t], acc) do
    mc_cabe(t, mc_cabe(clauses, acc))
  end

  defp mc_cabe([{:if, _, clauses}|t], acc) do
    mc_cabe(t, mc_cabe(clauses, acc))
  end

  defp mc_cabe([h|t], acc) when is_tuple(h) do
    mc_cabe(t, mc_cabe(tuple_to_list(h), acc))
  end

  defp mc_cabe([_|t], acc) do
    mc_cabe(t, acc)
  end
end
