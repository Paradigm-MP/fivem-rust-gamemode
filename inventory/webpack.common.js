const path = require('path');
const webpack = require('webpack');

module.exports = options => ({
    mode: options.mode,
    entry: options.entry,
    devServer: {
        contentBase: path.join(__dirname, 'client', 'ui'),
        compress: true,
        hot: true,
        watchContentBase: true,
        port: 9000,
    },
    devtool: 'inline-source-map',
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: [[
                            '@babel/preset-env', {
                                targets: {
                                    esmodules: true
                                }
                            }],
                            '@babel/preset-react']
                    }
                }
            },
            {
                test: [/\.s[ac]ss$/i, /\.css$/i],
                use: [
                    // Creates `style` nodes from JS strings
                    'style-loader',
                    // Translates CSS into CommonJS
                    'css-loader',
                    // Compiles Sass to CSS
                    'sass-loader',
                ],
            },
            {
                test: [/\.svg$/],
                use: {
                    loader: 'svg-url-loader',
                    options: {
                        limit: 10000
                    }
                }
            },
            {
                test: /\.(woff|woff2|eot|ttf|otf)$/,
                use: {
                    loader: 'null-loader'
                }
            }
        ]
    },
    resolve: {
        extensions: ['.js'],
    },
    output: {
        filename: 'app.js',
        path: path.resolve(__dirname, 'client', 'ui'),
        publicPath: path.resolve(__dirname, 'client', 'ui'),
    },
})