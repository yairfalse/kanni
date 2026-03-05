defmodule KanniWeb.Components.FocusPanel do
  @moduledoc """
  Center panel: tabbed view of the selected repo's state.
  Tabs: Changes (default), Graph, Activity, Status.
  """

  use Phoenix.Component

  attr :selected_repo, :map, default: nil
  attr :active_tab, :string, default: "changes"
  slot :changes
  slot :graph
  slot :activity
  slot :status

  def focus_panel(assigns) do
    assigns = assign(assigns, :tabs, tabs_for(assigns.selected_repo))

    ~H"""
    <div class="kanni-focus-panel">
      <div :if={@selected_repo || @active_tab == "status"} class="kanni-focus-content">
        <div class="kanni-tab-bar">
          <button
            :for={tab <- @tabs}
            class={"kanni-tab #{if @active_tab == tab, do: "active", else: ""}"}
            phx-click="switch_tab"
            phx-value-tab={tab}
          >
            {String.capitalize(tab)}
          </button>
        </div>
        <div class="kanni-tab-content">
          <div :if={@active_tab == "changes"}>
            {render_slot(@changes)}
          </div>
          <div :if={@active_tab == "graph"}>
            {render_slot(@graph)}
          </div>
          <div :if={@active_tab == "activity"}>
            {render_slot(@activity)}
          </div>
          <div :if={@active_tab == "status"}>
            {render_slot(@status)}
          </div>
        </div>
      </div>
      <div :if={!@selected_repo && @active_tab != "status"} class="kanni-focus-empty">
        <p class="kanni-empty-message">Select a repo to get started</p>
      </div>
    </div>
    """
  end

  defp tabs_for(nil), do: ~w(status)
  defp tabs_for(_repo), do: ~w(changes graph activity status)
end
