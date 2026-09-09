-- shortcut.luau — control-center quick toggle for tracking.
--
-- Add from Settings → Control Center shortcuts. Shows the current tracking
-- state (from the service's shared state) and toggles pause/resume on click.

local active = false

local function render()
  local s = noctalia.state.get("wdid_state") or {}
  local tracking = s.tracking ~= false
  active = tracking
  shortcut.setLabel(tracking and noctalia.tr("shortcut.label") or noctalia.tr("shortcut.description"))
  shortcut.setIcon(tracking and "clock-hour-4" or "player-pause")
  shortcut.setActive(tracking)
end

function onClick()
  noctalia.state.set("wdid_command", { op = "toggle" })
  -- Optimistic flip; the watch below corrects it on the next publish.
  active = not active
  render()
end

noctalia.state.watch("wdid_state", function(_value)
  render()
end)

render()
