# Source
# http://blog.pthompson.org/phoenix-liveview-livecomponent-modal

defmodule ClientAppWeb.ModalLive do
  use Phoenix.LiveComponent

  @defaults %{
    left_button: "Cancel",
    left_button_action: nil,
    right_button: "Accept",
    right_button_action: nil,
    right_button_param: nil
  }

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: _id} = assigns, socket) do
    {:ok, assign(socket, Map.merge(@defaults, assigns))}
  end

  def render(assigns) do
    modal_markup(assigns)
  end

  def handle_event(
    "right-button-click",
    _params,
    %{
      assigns: %{
        right_button_action: right_button_action,
        right_button_param: right_button_param
      }
    } = socket
  ) do
    send(
      self(),
      {__MODULE__,
      :button_clicked,
      %{action: right_button_action, param: right_button_param}}
    )

    {:noreply, socket}
  end

  def handle_event(
    "left-button-click",
    _params,
    %{
      assigns: %{
        left_button_action: left_button_action
      }
    } = socket
  ) do
    send(
    self(),
    {__MODULE__, :button_clicked, %{action: left_button_action}}
    )

    {:noreply, socket}
  end

  defp modal_markup(assigns) do
    ~L"""
    <div id="modal-<%= @id %>">
      <!-- Modal Background -->
      <div class="modal-container">
        <div class="modal-inner-container">
          <div class="modal-card">
            <div class="modal-inner-card">
              <!-- Title -->
              <%= if @title != nil do %>
              <div class="modal-title">
                <%= @title %>
              </div>
              <% end %>

              <!-- Body -->
              <%= if @body != nil do %>
              <div class="modal-body">
                <%= @body %>
              </div>
              <% end %>

              <!-- Buttons -->
              <div class="modal-buttons">
                  <!-- Left Button -->
                  <button class="btn btn-secondary"
                          type="button"
                          phx-click="left-button-click"
                          phx-target="#modal-<%= @id %>">
                    <div>
                      <%= @left_button %>
                    </div>
                  </button>
                  <!-- Right Button -->
                  <button class="btn btn-primary"
                          type="button"
                          phx-click="right-button-click"
                          phx-target="#modal-<%= @id %>">
                    <div>
                      <%= @right_button %>
                    </div>
                  </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
