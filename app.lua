local lapis = require("lapis")
local app = lapis.Application()
app:enable("etlua")
app.layout = require("views.layout")

local Model = require("lapis.db.model").Model
local Podcasts = Model:extend("podcasts")

app:get("/", function()
	return { render = "index" }
end)

app:get("/subscriptions", function(self)
	self.subs = Podcasts:select(nil, nil, { fields = "title" })
	return { render = "subscriptions" }
end)

return app
