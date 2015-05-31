exports.videos = {
    map: function(doc) {
        if ((doc.type == "mp4") || (doc.type == "mkv")) {
            emit(doc._id, null);
        }
    }
};

exports.genres = {
    map: function(doc) {
        if ((doc.type == "mp4") || (doc.type == "mkv")) {
            if (doc.genre) {
                emit(doc.genre, null);
            }
        }
    }
};

exports.titles = {
    map: function(doc) {
        if ((doc.type == "mp4") || (doc.type == "mkv")) {
            if (doc.title) {
                emit(doc.title, null);
            }
        }
    }
};
