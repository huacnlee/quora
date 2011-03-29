require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
# Rails.application.config.middleware.use OmniAuth::Strategies::GitHub, '6352f98cea40e3065c84', '13a033d194d3253fece0ebb24e3ed506aea53313'
Rails.application.config.middleware.use OmniAuth::Strategies::GitHub, '7c9fc4ac803e9e721284', '9543694a314a23a820adce0218a8d1e08870602f'

