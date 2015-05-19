/**
 * Filter functions to be exported from the design doc for _changes filtering.
 */

exports.videos = function(doc, req) {
    if (doc.type && doc.type === 'mp4') {
        return true;
    } else {
        return false;
    }
};
