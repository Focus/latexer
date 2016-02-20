fsPlus = require 'fs-plus'
fs = require 'fs-plus'
path = require 'path'

module.exports =
FindLabels =
  getLabelsByText: (text, file = "") ->
    labelRex = /\\(?:th)?label{([^}]+)}/g
    matches = []
    while (match = labelRex.exec(text))
      matches.push {label: match[1]}
    return matches unless file?
    inputRex = /\\(input|include){([^}]+)}/g
    while (match = inputRex.exec(text))
      matches = matches.concat(@getLabels(@getAbsolutePath(file, match[2])))
    matches

  getLabels: (file) ->
    if not fsPlus.isFileSync(file) #if file is not there try add possible extensions
      file = fsPlus.resolveExtension(file, ['tex'])
    return [] unless fsPlus.isFileSync(file)
    text = fs.readFileSync(file).toString()
    @getLabelsByText(text, file)

  getAbsolutePath: (file, relativePath) ->
    if (ind = file.lastIndexOf(path.sep)) isnt file.length
      file = file.substring(0,ind)
    path.resolve(file, relativePath)
