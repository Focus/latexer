const path = require('path');

module.exports = {
  resolveAbsolutePathToBibFile(candidatePath) {
    const pathToActiveFile = atom.workspace.getActiveTextEditor().getPath();
    const parentDirectoryOfActiveFile = path.dirname(pathToActiveFile);
    let pathToBibFile = candidatePath;
    // If the candidate path isn't an absolute path,
    // assume it's relative to the file being edited.
    if (!path.isAbsolute(pathToBibFile)) {
      pathToBibFile = path.join(parentDirectoryOfActiveFile, pathToBibFile);
    }
    return pathToBibFile;
  }
};
