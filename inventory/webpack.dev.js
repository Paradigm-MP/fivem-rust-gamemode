const path = require('path');
const webpack = require('webpack');

module.exports = require('./webpack.common')({
    mode: 'development',

    // Add hot reloading in development
    entry: [
        path.resolve(__dirname, 'src', 'js', 'index.js'),
    ],

    // Add development plugins
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
    ],
    devtool: 'eval-source-map',
    performance: {
        hints: false,
    },
    output: {
        filename: 'app.js',
        path: path.resolve(__dirname, 'client', 'ui'),
        publicPath: path.resolve(__dirname, 'client', 'ui'),
    },
});