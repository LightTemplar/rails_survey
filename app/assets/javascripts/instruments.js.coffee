jQuery ->
  $('.sortable').sortable({
    cursor: 'move',
    handle: '.move-question'
    update: ->
      $('.question-number:visible').each (index, el)->
        $(el).text(index+1)
  })

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).siblings('input[type=hidden]').val('1')
    $(this).closest('div.well').hide()
    updateQuestionNumbers()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    updateQuestionNumbers()
    event.preventDefault()

  $('form').on 'click', '.move-up', (event) ->
    question = $(this).closest('div.question')
    previousQuestion = question.prevAll('.question').first()
    question.after(previousQuestion)
    updateQuestionNumbers()
    event.preventDefault()

  $('form').on 'click', '.move-down', (event) ->
    question = $(this).closest('div.question')
    nextQuestion = question.nextAll('.question').first()
    question.before(nextQuestion)
    updateQuestionNumbers()
    event.preventDefault()

  $('form').on 'click', '.show-follow-up-btn', (event) ->
    followUpQuestion = $(this).siblings('div.follow-up-question')
    followUpSelect = followUpQuestion.find('select.question-identifier-list')
    $(this).hide("slow")
    $(this).siblings('div.follow-up-explanation').show("slow")
    followUpQuestion.show("slow")
    $.each(questionIdentifiers().splice(0, questionNumber(followUpQuestion)), (index, item) ->
      followUpSelect.append(new Option(item, item))
    )
    event.preventDefault()

  questionIdentifiers = ->
    identifiers = []
    $('.question-identifier').each ->
      identifiers.push($(this).val())
    identifiers

  updateQuestionNumbers = ->
    $('.number-in-instrument:visible').each (index, el)->
      $(el).val(index+1)
      
  questionNumber = (el) ->
    el.closest('div.question').prevAll('.question').size()
