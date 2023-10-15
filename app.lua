local lapis = require("lapis")
local app = lapis.Application()
app:enable("etlua")

local Model = require("lapis.db.model").Model
local Podcasts = Model:extend("podcasts")

app:get("/", function()
	return { render = "index" }
end)

app:get("/subscriptions", function(self)
	self.subs = Podcasts:select(nil, nil, { fields = "title, id" })
	return { render = "subscriptions" }
end)

app:get("/subscriptions/:id", function(self)
	self.pod = Podcasts:find(self.params.id)
	return { render = "subscription" }
end)

return app
