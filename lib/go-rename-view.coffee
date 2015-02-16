{BufferedProcess} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class GoRenameView extends View
  @content: ->
    @div =>
      @div 'rename identifier:'
      @subview 'miniEditor', new TextEditorView(mini: true)

  initialize: ->
    atom.commands.add 'atom-text-editor', 'go-rename:toggle', => @toggle()

    @panel = atom.workspace.addModalPanel item: this, visible: false

    @miniEditor.on 'blur', => @close()
    atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
    atom.commands.add @miniEditor.element, 'core:cancel', => @close()

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    @panel.hide()
    if @focusElement?.isOnDom()
      @focusElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    buffer = atom.workspace.getActiveTextEditor()
    buffer.save() if buffer.isModified()
    buffer.moveToBeginningOfWord()
    buffer.selectToEndOfWord()

    wordStart = buffer.getSelectedBufferRange().start
    @byteOffset = buffer.getTextInBufferRange([[0,0], wordStart]).length
    @filePath = buffer.getPath()

    @focusElement = $(':focus')
    @panel.show()
    @miniEditor.getModel().setText buffer.getSelectedText()
    @miniEditor.getModel().selectAll()
    @miniEditor.focus()

  confirm: ->
    @close()
    text = @miniEditor.getModel().getText()
    if text.length > 0
      command = atom.config.get 'go-rename.path'
      args = ['-offset', "#{@filePath}:##{@byteOffset}", '-to', text]
      stderr = (output)=>
        @result = output
      exit = (code)=>
        if code == 0
          atom.notifications.addSuccess @result
        else
          atom.notifications.addError @result
      process = new BufferedProcess({command, args, stderr, exit})
