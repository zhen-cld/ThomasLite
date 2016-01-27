SlideView = require("views/slide")

theAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")

class ConstructView extends SlideView
  template: require("./template")

  events: ->
    "iostap .word-hidden": "activateWord"
    "iostap .option": "selectOption"

  show: ->
    @setEl @el.querySelector(".option"), "option"

  onRefresh: ->
    super
    @show()

  # The serialize method is your chance to filter data on it's way from the CMS
  # to the template. Do the heavy-lifting here rather than putting the logic
  # into the jade template.
  serialize: ->
    data = super

    title = data.title
    words = data.words

    title = "" if not title?

    for { replaces, incorrect }, i in words
      title = title.replace(replaces, "{{#{i}}}")

    data.components =
      for component in title.split(" ")
        index = +component.match(/\{\{(\d+)\}\}/)?[1]
        if words[index]?
          word = words[index]
          options = _.shuffle word.incorrect.concat word.replaces

        klass: "delay-#{_.random(3)} scale-#{_.sample(["down", "up"])}"
        word: words[index]?.replaces or component
        options: words[index]? and options

    data

  activateWord: (e) ->
    el = e.currentTarget

    if el is @getEl("active")
      return
    else
      e.stopImmediatePropagation()
      @getEl("active")?.classList.remove "active"
      @setEl el, "active"
      el.classList.add "active"

  selectOption: (e) ->
    el = e.currentTarget
    activeWord = @getEl("active")

    @getEl(".option")?.classList.remove "active"
    @setEl el, ".option"
    el.classList.add "active"

    isCorrect = el.dataset.word is activeWord.dataset.word

    if isCorrect
      activeWord.classList.add "correct"
      activeWord.classList.remove "active"


module.exports = ConstructView
