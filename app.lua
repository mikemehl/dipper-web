local lapis = require("lapis")
local app = lapis.Application()
app:enable("etlua")

local Model = require("lapis.db.model").Model
local Podcasts = Model:extend("podcasts")
local Episodes = Model:extend("episodes")

local function get_recent_episodes(page_limit)
  return Episodes:paginated(
    "INNER JOIN podcasts ON episodes.podcast_id = podcasts.id ORDER BY episodes.pub_date DESC",
    nil,
    {
      fields = [[
      episodes.id AS id, 
      episodes.pub_date AS date, 
      episodes.title AS title, 
      episodes.description AS description, 
      episodes.enclosure_url AS enclosure_url,
      podcasts.id AS pod_id, 
      podcasts.title AS pod_title
      ]],
      per_page = page_limit,
    }
  )
end

app:get("/", function(self)
  local paginator = get_recent_episodes(10)
  if paginator then
    self.episodes = paginator:get_page(1)
  end
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

app:get("subscription", "/subscription/:id(/:id_or_action)", function(self)
  if self.params.id_or_action == "episodes" then
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

app:get("episodes", "/episodes(/:page)", function(self)
  local paginator = get_recent_episodes(50)
  if paginator then
    self.page = tonumber(self.params.page) or 1
    self.num_pages = paginator:num_pages()
    if self.page < 1 then
      self.page = 1
    elseif self.page >= self.num_pages then
      self.page = self.episodes.num_pages()
    end
    self.episodes = paginator:get_page(self.page)
  end
  return { render = "episodes" }
end)

app:get("audio", "/audio/:id", function(self)
  self.episode = Episodes:find(self.params.id)
  return { render = "audio" }
end)

return app
