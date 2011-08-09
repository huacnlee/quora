require 'yaml' 
YAML::ENGINE.yamler= 'syck'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Quora::Application.initialize!
