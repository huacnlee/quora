require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
Rails.application.config.middleware.use OmniAuth::Strategies::Douban, '01e47acb66c2abfe05ad7062344803fa', '6b52b51826dd983a'
Rails.application.config.middleware.use OmniAuth::Strategies::Tsina, '614904046', '932aa3b133bf26cc8a4398ec5ab5fbb5'
Rails.application.config.middleware.use OmniAuth::Strategies::Tqq, 'd474e02630a849a5bbbf13bca0f9795f', '279bad9e954cc2b3f9988df534b4be49'

