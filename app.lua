local lapis = require("lapis")
local app = lapis.Application()
app:enable("etlua")

local Model = require("lapis.db.model").Model
local Podcasts = Model:extend("podcasts")
local Episodes = Model:extend("episodes")

app:get("/", function()
  return { render = "index" }
end)

app:get("subscriptions", "/subscriptions(/:sort)", function(self)
  self.sort = self.params.sort or "title"
  if self.sort == "title" then
    self.subs = Podcasts:select("ORDER BY title", nil, { fields = "title, id" })
  else
    self.subs = Podcasts:select(nil, nil, { fields = "title, id" })
  end
  return { render = "subscriptions" }
end)

app:get("subscription", "/subscription/:id(/:id_or_episodes)", function(self)
  if self.params.id_or_episodes == "episodes" then
    print("HELLO")
    self.episodes = Episodes:select("WHERE podcast_id = ?", self.params.id)
    return { render = "pod_episodes" }
  elseif type(self.params.id) == "number" then
    self.episode = Episodes:find(self.params.id)
    return { render = "episode" }
  else
    self.pod = Podcasts:find(self.params.id)
    return { render = "subscription" }
  end
end)

app:get("audio", "/audio/:id", function(self)
  self.episode = Episodes:find(self.params.id)
  return { render = "audio" }
end)

return app
