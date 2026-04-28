local gui = {
  activeGroup = nil,
}

local f = "core/gui/gui_"

gui.button = require(f .. "button")
gui.page = require(f .. "page")

-- Aliases plus lisibles pour l'utilisation côté scènes.
gui.Button = gui.button
gui.Page = gui.page
gui.Panel = gui.page

function gui.setActiveGroup(group)
  if gui.activeGroup == group then
    if group then
      group.active = true

      if group.selectFirstAvailable and not group.current then
        group:selectFirstAvailable()
      elseif group.selectIndex and not group.current and #group > 0 then
        group:selectIndex(group.selectedIndex or 1)
      end
    end

    return group
  end

  if gui.activeGroup then
    gui.activeGroup.active = false
  end

  gui.activeGroup = group

  if group then
    group.active = true

    if group.selectFirstAvailable and not group.current then
      group:selectFirstAvailable()
    elseif group.selectIndex and not group.current and #group > 0 then
      group:selectIndex(group.selectedIndex or 1)
    end
  end

  return group
end

function gui.getActiveGroup()
  return gui.activeGroup
end

function gui.clearActiveGroup(group)
  if not group or gui.activeGroup == group then
    if gui.activeGroup then
      gui.activeGroup.active = false
    end

    gui.activeGroup = nil
  end
end

function gui.load()
end

function gui.update(dt)
end

function gui.draw()
end

function gui.mousepressed(x, y, button, istouch, presses)
end

function gui.keypressed(k, s, isrepeat)
end

return gui
