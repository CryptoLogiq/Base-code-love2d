return {
  image = "assets/spritesheet_player_clean.png",
  frameW = 32,
  frameH = 32,
  marginX = 0,
  marginY = 0,
  spacingX = 0,
  spacingY = 0,
  offsetX = 0,
  offsetY = 0,
  animations = {
    idle = {
      frames = { 1, 2, 3, 4 },
      fps = 6,
      loop = true,
    },
    walk = {
      frames = { 5, 6, 7, 8 },
      fps = 10,
      loop = true,
    },
    jump = {
      frames = { 9, 10, 11, 12 },
      fps = 8,
      loop = false,
    },
    attack = {
      frames = { 13, 14, 15, 16 },
      fps = 12,
      loop = false,
    },
  },
}
