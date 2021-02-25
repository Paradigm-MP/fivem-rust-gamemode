const path = require('path');

module.exports = require('./webpack.common')({
    mode: 'production',

    entry: [path.join(__dirname, 'src', 'js', 'index.js')],

    performance: {
        assetFilter: assetFilename =>
            !/(\.map$)|(^(main\.|favicon\.))/.test(assetFilename),
    },
});