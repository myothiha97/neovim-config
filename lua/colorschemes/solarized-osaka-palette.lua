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
  },
  blue = {
    blue300 = "#49aef5",
    balanced = "#4488ab",
    brighter = "#268bd2",
  },
}

-- Change only these selections to try another saved color.
return {
  yellow = variants.yellow.darker,
  red = variants.red.muted_contrast,
  blue = variants.blue.balanced,
}

-- Theme-native red alternative kept from earlier testing:
-- c.red = c.red300
-- c.red500 = c.red300
