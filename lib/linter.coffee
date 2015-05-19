linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
{Range} = require 'atom'

class LinterTern extends Linter

  @syntax: 'source.js'
  linterName: 'tern-lint'
  _manager: null

  constructor: (editor) ->
    @_manager = atom.packages.getLoadedPackage('atom-ternjs').mainModule.manager
    super(editor)

  lintFile: (filePath, callback) ->
    return unless @_manager.useLint
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    URI = editor.getURI()
    text = editor.getText()
    @_manager.client?.update(URI, text).then =>
      @_manager.client.lint(URI, text).then (data) =>
        return unless data.messages
        editor = atom.workspace.getActiveTextEditor()
        buffer = editor.getBuffer()
        messages = []
        for message in data.messages
          positionFrom = buffer.positionForCharacterIndex(message.from)
          positionTo = buffer.positionForCharacterIndex(message.to)
          messages.push
            message: message.message,
            line: positionFrom.row,
            col: positionFrom.column,
            level: message.severity,
            range: new Range([positionFrom.row, positionFrom.column], [positionTo.row, positionTo.column])
            linter: 'tern-lint'
        return callback(messages)

module.exports = LinterTern
