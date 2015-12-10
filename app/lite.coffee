load = (name, path, done) ->
  if /\.js$/.test name
    el = document.createElement("script")
    el.setAttribute("type", "text/javascript")
    el.setAttribute("src", "#{path}/#{name}")

  else if /\.css$/.test name
    el = document.createElement("link")
    el.setAttribute("rel", "stylesheet")
    el.setAttribute("type", "text/css")
    el.setAttribute("href", "#{path}/#{name}")

  el.addEventListener "load", done
  document.getElementsByTagName("head")[0].appendChild(el)

Lite =
  initialize: (apikey) ->
    from = "http://localhost:3333"
    files = [
      "css/app.css"
      "js/vendor.js"
      "js/app.js"
    ]

    do next = ->
      if files.length
        file = files.shift()
        load file, from, next
      else
        new (require "lib/logger")(true, "THOMAS", "#46B4E9") "Hello!"
        require("app").initialize()

module.exports = Lite
