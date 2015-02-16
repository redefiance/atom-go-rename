module.exports =
  config:
    path:
      title: 'gorename path'
      description: 'Set this if the gorename executable is not found within your PATH'
      type: 'string'
      default: 'gorename'

  activate: ->
    new (require './go-rename-view')
