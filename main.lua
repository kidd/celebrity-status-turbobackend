local turbo = require "turbo"

local ExampleHandler = class("ExampleHandler", turbo.web.RequestHandler)

function ExampleHandler:is_dead()
   local name = self:get_argument"name"
   local wiki_page = string.format("%s%s%s",
                                   "http://en.wikipedia.org/w/api.php?action=query&titles=",
                                   name,
                                   "&prop=revisions&rvprop=content&format=json&rvsection=0")
   local res = coroutine.yield(
      turbo.async.HTTPClient():fetch(wiki_page))
   if res.error then
      return false
   else
      return res.body:match("death_date")
   end
end

function ExampleHandler:get()
   self:set_header('Access-Control-Allow-Origin', '*')
   self:write({name = self:get_argument'name', is_dead = self:is_dead()})
end

turbo.web.Application({
    {"^/$", ExampleHandler}
}):listen(8888)

turbo.ioloop.instance():start()
