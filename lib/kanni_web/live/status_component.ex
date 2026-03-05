defmodule KanniWeb.StatusComponent do
  @moduledoc """
  Agent status view — shows AI agents active across repos.
  """

  use KanniWeb, :live_component

  @max_visible 5

  @impl true
  def update(assigns, socket) do
    agents = assigns.agents
    {active, idle} = Enum.split_with(agents, & &1.active)

    # Show all active + idle up to max, then collapse
    visible_idle = Enum.take(idle, max(0, @max_visible - length(active)))
    hidden_count = length(idle) - length(visible_idle)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       active: active,
       visible_idle: visible_idle,
       hidden_count: hidden_count
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="kanni-status">
      <div :if={@agents == []} class="kanni-status-line">
        <span class="kanni-status-dot dim"></span>
        <span class="kanni-status-key">no agents detected</span>
      </div>

      <div
        :for={agent <- @active}
        class="kanni-agent-row clickable"
        phx-click="select_repo"
        phx-value-path={agent.repo_path}
      >
        <span class="kanni-status-dot clean"></span>
        <span class="kanni-agent-repo">{repo_name(agent.repo_path)}</span>
        <span class="kanni-agent-name">{agent.name}</span>
        <span class="kanni-agent-state active">active</span>
      </div>

      <div
        :for={agent <- @visible_idle}
        class="kanni-agent-row clickable"
        phx-click="select_repo"
        phx-value-path={agent.repo_path}
      >
        <span class="kanni-status-dot dim"></span>
        <span class="kanni-agent-repo">{repo_name(agent.repo_path)}</span>
        <span class="kanni-agent-name">{agent.name}</span>
        <span class="kanni-agent-state">idle</span>
      </div>

      <div :if={@hidden_count > 0} class="kanni-status-line">
        <span class="kanni-status-val">+ {@hidden_count} more idle</span>
      </div>
    </div>
    """
  end

  defp repo_name(path), do: Path.basename(path)
end
