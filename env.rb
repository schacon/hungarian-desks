# just so we can include all this default crap in a one-liner
# and not dirty up our beautiful scripts
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'active_support/all'
Dotenv.load