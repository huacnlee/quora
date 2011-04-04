require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, OpenID::Store::Filesystem.new("/tmp"), :name => "google",  :identifier => "https://www.google.com/accounts/o8/id"
  provider :douban , '01e47acb66c2abfe05ad7062344803fa', '6b52b51826dd983a'
  provider :tsina, '614904046', '932aa3b133bf26cc8a4398ec5ab5fbb5'
  provider :tqq, 'd474e02630a849a5bbbf13bca0f9795f', '279bad9e954cc2b3f9988df534b4be49'
  provider :t163, 'BMO70rvqyCs0Pby5', 'AwRwtzF1eRPVrZa5rzusedS8JdM79pNj'
  provider :tsohu, 'XtA4sAn6dpVnqIMNucge', 'URzg4g)Vj9M(9VdMarXIZddgQ8!(5m8cehkH^WB0'
  provider :github, '11f1ad7b2ef9263b2ead', '4f07422d1e499126e2fb247dd547b670e01a47d1'
end
