-- vim: foldmethod=marker

local util           = require("util")
local leader         = require("leader")
local caffeine       = require("caffeine")
local appbindings    = require("appbindings")
local browsebindings = require("browsebindings")
local itunes         = require("itunes")

local geometry      = hs.geometry
local hotkey        = hs.hotkey
local layout        = hs.layout
local reload        = hs.reload
local screen        = hs.screen
local spotify       = hs.spotify
local toggleConsole = hs.toggleConsole
local window        = hs.window

-- don't animate windows during transitions
window.animationDuration = 0

-- hotkey.bind({"cmd", "ctrl"}, "9", function()
--   print(window.focusedWindow():application():bundleID())
-- end)

browsebindings.setup({"cmd", "ctrl", "option", "shift"}, {
  ["o"] = "https://octobox.shopify.io",
  ["t"] = "https://twitter.com",
  ["n"] = "https://news.ycombinator.com",
  ["f"] = "https://facebook.com",
  ["i"] = "https://instapaper.com/u",
  ["r"] = "https://reddit.com",
  ["p"] = "https://github.com/pulls",
})

-- [2] = "com.apple.iTunes",
appbindings.setup({"cmd", "ctrl"}, {
  [1] = "com.googlecode.iterm2",
  [2] = "com.apple.Music",
  [3] = "com.brave.Browser",
  [4] = "com.tinyspeck.slackmacgap",
  [5] = "com.apple.Reminders",
  [6] = "com.apple.iChat",
  [7] = "com.apple.Mail",
  [8] = "com.microsoft.vscode",
  [9] = "com.kapeli.dashdoc",
})

-- hs.hotkey.bind({"cmd", "ctrl"}, "2", itunes.toggleLibrary)
-- hs.hotkey.bind({"cmd", "ctrl"}, "m", itunes.toggleMiniPlayer)

-- Secondary screen watcher / autolayout {{{
local function setupSecondaryScreen()
  local s = "Color LCD"
  layout.apply({
    {"Slack",    nil, s, geometry.rect(0,    0,    0.65, 1),    nil, nil},
    {"Things",   nil, s, geometry.rect(0.65, 0,    0.35, 0.38), nil, nil},
    {"Messages", nil, s, geometry.rect(0.65, 0.38, 0.35, 0.62), nil, nil},
  })
end

if #screen.allScreens() > 1 then setupSecondaryScreen() end
screen.watcher.new(function()
  if #screen.allScreens() > 1 then setupSecondaryScreen() end
end):start()

-- }}}

-- Layout {{{

function setCurrentLeft()
  util.setFrameForCurrent(function(x, y, w, h) return x, y, w/2, h end)
end

function setCurrentRight()
  util.setFrameForCurrent(function(x, y, w, h) return w/2, y, w/2, h end)
end

-- }}}

caffeine.start()

leader.new({"cmd", "shift"}, "`"):bindall({
  p = setupSecondaryScreen,

  r = reload,
  c = toggleConsole,

  s = setCurrentLeft,
  f = setCurrentRight,
  b = caffeine.clicked,
})
