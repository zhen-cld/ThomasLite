SlideView = require("views/slide")
Draggy = require("./components/draggy")

class ConstructView extends SlideView
  template: require("./template")

  events: ->
    "iostap .word-hidden": "activateWord"
    "iostap .option": "selectOption"

  show: ->
    @setEl @el.querySelector(".option"), "option"
    draggies = @el.querySelectorAll(".draggy")
    @draggies =
      for el, i in draggies
        draggy = new Draggy
          el: el
          lock: "x"
          allowPropagation: true

        @listenTo draggy, "drag", @onDrag
        @listenTo draggy, "drop", @onDrop

        draggy.lock()
        draggy

    @el.classList.add "ready"

  onDrag: (draggy, isInitialDrag) ->
    isActive = false
    unless isInitialDrag
      Backbone.trigger "canceltap"

    @transformEl draggy.el,
      y: draggy.y
      scale: 1.05
      transition: if isInitialDrag then "all 300ms" else "none"

  onDrop: (draggy, isReset) ->
    wordHeight = draggy.offset.height / 3

    if draggy.y <= -wordHeight
      y = -wordHeight
      index = 2
    else if draggy.y >= wordHeight
      y = wordHeight
      index = 0
    else
      y = 0
      index = 1

    {left, top, width, height} = draggy.offset

    if isReset
      allWords   = draggy.el.querySelectorAll(".option")
      activeWord = allWords[index]
      activeData = activeWord.dataset.word
      el         = draggy.$el.parents(".word-hidden").get(0)
      isCorrect  = activeData is el.dataset.word

      for word, i in allWords
        word.classList.remove("active") if i isnt index

      if isCorrect
        el.classList.add "correct"
        el.classList.remove "active"
      else
        activeWord.classList.add "active"

      @transformEl draggy.el,
        y: draggy.y
        transition: "all 300ms"
    else
      draggy.reset y: y
      @setState("touched")

  onRefresh: ->
    super
    @show()

  # The serialize method is your chance to filter data on it's way from the CMS
  # to the template. Do the heavy-lifting here rather than putting the logic
  # into the jade template.
  serialize: ->
    data  = super
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
        index: index

    data

  activateWord: (e) ->
    el = e.currentTarget
    return if el is @getEl("currentWord")

    e.stopImmediatePropagation()

    index = el.dataset.index
    draggy = @draggies[index]
    draggy.unlock()

    if @getEl("currentWord")?
      prevIndex = @getEl("currentWord").dataset.index
      @draggies[prevIndex].lock()
      @getEl("currentWord").classList.remove "active"

    @setEl el, "currentWord"
    el.classList.add "active"

  selectOption: (e) ->
    el = e.currentTarget
    activeWord = @getEl("currentWord")
    index = el.dataset.index

    @draggies[activeWord.dataset.index].reset
      y: -(index - 1) * el.offsetHeight


module.exports = ConstructView
