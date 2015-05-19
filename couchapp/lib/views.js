exports.videos = {
    map: function(doc) {
        if (doc.type == "mp4") {
            emit(doc._id, null);
        }
    }
};

exports.genres = {
    map: function(doc) {
        if (doc.type == "mp4") {
            if (doc.genre) {
                emit(doc.genre, null);
            }
        }
    }
};

exports.titles = {
    map: function(doc) {
        if (doc.type == "mp4") {
            if (doc.title) {
                emit(doc.title, null);
            }
        }
    }
};
