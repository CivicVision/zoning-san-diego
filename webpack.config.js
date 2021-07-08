var webpack = require('webpack');
module.exports = {
  entry: {
    site: ['whatwg-fetch','./source/javascripts/all.js']
  },

  devtool: 'eval-source-map',
  output: {
    path: __dirname + '/.tmp/dist',
    filename: 'javascripts/[name].js',
  },

  module: {
    loaders: [
      { test: /\**\/*coffee$/, loader: "coffee-loader", exclude: /node_modules|\.tmp/},
      { test: /\.json$/, loader: 'json-loader' },
    ],
    noParse: [ ],
  },
  resolve: {
    extensions: ['', '.js', '.json', '.coffee'],
    alias: { }
  },
  plugins: [
    new webpack.ProvidePlugin({
    }),
    new webpack.DefinePlugin({
      GEOCODE_API_KEY: JSON.stringify(process.env.GEOCODE_API_KEY),
    }),
  ]
};
