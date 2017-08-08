
// function allFiles(fileType, dir) {
//     console.log('all ' + fileType + ' in ' + dir)
//     return ['all_files', 'included']
// };
// exports.allFiles = allFiles;

var path = require('path'), fs=require('fs');

function fromDir(startPath,filter){
    if (!fs.existsSync(startPath)){
        console.log("no dir ",startPath);
        return;
    }

    allFiles = []
    var files=fs.readdirSync(startPath);
    for(var i=0;i<files.length;i++){
        var filename=path.join(startPath,files[i]);
        var stat = fs.lstatSync(filename);
        if (stat.isDirectory()){
           allFiles = allFiles.concat(fromDir(filename,filter));
        }
        else if (filter.test(filename)) {
           allFiles.push(filename);
        }
    };
    return allFiles
};

exports.fromDir = fromDir;

dir = '/Users/vitalis/Documents/Msc_project/bluSky/thesis/dissertation'
allFiles = fromDir(dir, /\.tex$/);
console.log(allFiles);
