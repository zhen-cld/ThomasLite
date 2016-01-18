SlideView = require("views/slide")

class ConstructView extends SlideView
  template: require("./template")

  events: ->
    "iostap .btn-next": "next"
    "iostap .btn-exit": "exit"

  # The serialize method is your chance to filter data on it's way from the CMS
  # to the template. Do the heavy-lifting here rather than putting the logic
  # into the jade template.
  serialize: ->
    data = super

    { title, words } = data
    title = "" if not title?

    words =
      for {replaces, incorrect}, i in words when replaces and incorrect
        title = title.replace(replaces, "{{#{i}}}")
        {replaces, incorrect}

    data.components =
      for component in title.split(" ")
        index = +component.match(/\{\{(\d+)\}\}/)?[1]
        klass: "delay-#{_.random(3)} scale-#{_.sample(["down", "up"])}"
        incorrect: words[index]?.incorrect
        replaces: words[index]?.replaces or component

    data

  show: ->
  hide: ->
  beforeShow: ->
  beforeHide: ->
  afterShow:  ->

module.exports = ConstructView
