/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ListLabels;
const fsPlus = require('fs-plus');
const fs = require('fs-plus');
const path = require('path');

module.exports =
(ListLabels = {
   fromDir(startPath,filter){
      allLabels = []
       if (!fs.existsSync(startPath)){
           console.log("no dir ",startPath);
           return;
       }

       var files=fs.readdirSync(startPath);
       for(var i=0;i<files.length;i++){
           var filename=path.join(startPath,files[i]);
           var stat = fs.lstatSync(filename);
           if (stat.isDirectory()){
              allLabels = allLabels.concat(this.fromDir(filename,filter));
           }
           else if (filter.test(filename)) {
             text = fs.readFileSync(filename).toString()
             labels = this.getLabelsByText(text, filename)
              allLabels.push(labels);
           }
       };

       labels = []
       for (var i = 0; i < allLabels.length; i++) {
          labels = labels.concat(allLabels[i])
       }

       return labels
   },

  getLabelsByText(text, file) {
    let match;
    if (file == null) { file = ""; }
    const labelRex = /\\(?:th)?label{([^}]+)}/g;
    let matches = [];
    while (match = labelRex.exec(text)) {
      matches.push({label: match[1]});
    }
    if (file == null) { return matches; }
    const inputRex = /\\(input|include){([^}]+)}/g;
    while (match = inputRex.exec(text)) {
      matches = matches.concat(this.getLabels(this.getAbsolutePath(file, match[2])));
    }
    return matches;
  },

  getLabels(file) {
    //if file is not there try add possible extensions
    if (!fsPlus.isFileSync(file)) {
      file = fsPlus.resolveExtension(file, ['tex']);
    }
    if (!fsPlus.isFileSync(file)) { return []; }
    const text = fs.readFileSync(file).toString();
    return this.getLabelsByText(text, file);
  },

  getAbsolutePath(file, relativePath) {
    let ind;
    if ((ind = file.lastIndexOf(path.sep)) !== file.length) {
      file = file.substring(0,ind);
    }
    return path.resolve(file, relativePath);
  }
});

// dir = '/Users/vitalis/Documents/Msc_project/bluSky/thesis/dissertation'
// allFiles = ListLabels.fromDir(dir, /\.tex$/);
// console.log(allFiles);
