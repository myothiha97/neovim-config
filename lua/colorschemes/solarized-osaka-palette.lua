-- Previously tested colors are kept as named choices for quick switching.
local variants = {
  yellow = {
    brighter = "#baac0d",
    darker = "#a3970b",
  },
  red = {
    vivid = "#e03857",
    bright = "#ab3a4f",
    lighter = "#b83e55",
    bright_red = "#b83549",
    lower_contrast = "#ad4454",
    muted_contrast = "#c75b6b",
    darker = "#993141",
    magenta = "#b02669",
    crimson = "#bf2c47",
    red300 = "#F6524F",
    red700 = "#B7211F",
    -- hsl(12, 42, 50). Less saturated than both stock orange (#c94c16) and
    -- muted_contrast, with hue pulled back out of the pink range.
    terracotta = "#b55f4a",
  },
  blue = {
    blue300 = "#49aef5",
    balanced = "#4488ab",
    brighter = "#268bd2",
    -- hsl(205, 80, 56). Saturated like blue300, but held level with
    -- green/cyan/yellow in perceived lightness so blue stays in the accent band.
    vivid = "#359ee9",
    -- hsl(205, 80, 53). Same hue and saturation as vivid, three points darker so
    -- blue sits level with cyan/green instead of leading the accent band.
    deeper = "#2797e7",
    -- hsl(198, 75, 46). Leans toward cyan and drops chroma about a fifth versus
    -- deeper, staying clearly blue and level with green in the accent band.
    azure = "#1d98cd",
  },
}

-- Change only these selections to try another saved color.
return {
  yellow = variants.yellow.darker,
  red = variants.red.terracotta,
  blue = variants.blue.azure,
}

-- Theme-native red alternative kept from earlier testing:
-- c.red = c.red300
-- c.red500 = c.red300
