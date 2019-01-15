App.filter 'propertyFilter', ->
  (items, properties) ->
    output = []
    if angular.isArray(items)
      keys = Object.keys(properties)
      items.forEach (item) ->
        itemMatches = false
        i = 0
        while i < keys.length
          property = keys[i]
          text = properties[property].toLowerCase()
          if item[property].toString().toLowerCase().indexOf(text) != -1
            itemMatches = true
            break
          i++
        if itemMatches
          output.push item
        return
    else
      output = items
    output
