#!/usr/bin/env bash

# Close all open windows
hyprctl dispatch 'function()
  for _, win in ipairs(hl.get_windows()) do
    hl.dispatch(hl.dsp.window.close({ window = win }))
  end
end'

# Move to first workspace
hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
