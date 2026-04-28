local assets = {
  images = {},
  fonts = {},
}

function assets.newImage(path, settings)
  if not path then
    return nil
  end

  if assets.images[path] then
    return assets.images[path]
  end

  if love.filesystem and love.filesystem.getInfo and not love.filesystem.getInfo(path) then
    return nil
  end

  local image = love.graphics.newImage(path)

  if settings and settings.filter then
    local min = settings.filter.min or settings.filter[1] or "nearest"
    local mag = settings.filter.mag or settings.filter[2] or min
    image:setFilter(min, mag)
  end

  assets.images[path] = image
  return image
end

function assets.newFont(path, size)
  size = size or 12
  local key = tostring(path) .. ":" .. tostring(size)

  if assets.fonts[key] then
    return assets.fonts[key]
  end

  local font

  if path then
    font = love.graphics.newFont(path, size)
  else
    font = love.graphics.newFont(size)
  end

  assets.fonts[key] = font
  return font
end

function assets.clearCache()
  assets.images = {}
  assets.fonts = {}
end

return assets
