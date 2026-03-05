defmodule Kanni.Status do
  @moduledoc """
  Pure query module for system status. No process — just functions
  that aggregate agent state from detector plugins.
  """

  @doc "Returns all detected agents across all detector plugins."
  def agents do
    Kanni.Plugin.Registry.agent_detectors()
    |> Enum.flat_map(fn mod ->
      try do
        mod.detect_agents()
      rescue
        _ -> []
      end
    end)
    |> Enum.sort_by(&{!&1.active, &1.repo_path})
  end

  @doc "Summary counts for header display."
  def agent_summary do
    all = agents()
    active = Enum.count(all, & &1.active)
    %{total: length(all), active: active, idle: length(all) - active}
  end
end
