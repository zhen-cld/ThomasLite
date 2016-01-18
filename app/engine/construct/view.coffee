SlideView = require("views/slide")

theAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")

class ConstructView extends SlideView
  template: require("./template")

  templates:
    letters: require("./components/letters")

  events: ->
    "iostap .word-hidden": "activateWord"
    "iostap .letter": "selectLetter"

  show: ->
    @setEl @el.querySelector(".word-letters"), "letters"

  # The serialize method is your chance to filter data on it's way from the CMS
  # to the template. Do the heavy-lifting here rather than putting the logic
  # into the jade template.
  serialize: ->
    data = super

    title = data.title
    words = data.words

    title = "" if not title?

    for word, i in words
      title = title.replace(word, "{{#{i}}}")

    data.components =
      for component in title.split(" ")
        index = +component.match(/\{\{(\d+)\}\}/)?[1]
        klass: "delay-#{_.random(3)} scale-#{_.sample(["down", "up"])}"
        word: words[index] or component
        hidden: words[index]?

    data

  activateWord: (e) ->
    el = e.currentTarget

    @getEl("active")?.classList.remove "active"

    @setEl el, "active"
    el.classList.add "active"
    @activeNextLetter()

    extra = _.sample theAlphabet, 2
    word  = el.dataset.word.split("")
    mixed = _.shuffle word.concat(extra)

    @getEl("letters").classList.remove "active"

    window.setTimeout =>
      @getEl("letters").innerHTML = @templates.letters
        word: mixed
      @getEl("letters").classList.add "active"
    , 300

  selectLetter: (e) ->
    el = e.currentTarget
    next = @getEl("active").querySelector(".hidden-letter")

    isCorrect = el.dataset.letter.toLowerCase() is next.dataset.letter.toLowerCase()

    if isCorrect
      next.classList.add "visible-letter"
      next.classList.remove "hidden-letter"
      el.classList.add "disabled"
      @activeNextLetter()
    else
      el.classList.add "incorrect"
      window.setTimeout (-> el.classList.remove "incorrect"), 300

    unless @el.querySelector(".hidden-letter")
      @showAnswer()

  activeNextLetter: ->
    @el.querySelector(".hidden-letter.active")?.classList.remove "active"

    next = @getEl("active").querySelector(".hidden-letter")
    next?.classList.add "active"

module.exports = ConstructView
