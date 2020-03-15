source "https://rubygems.org"

gem "jekyll", "4.0.0"
gem "minima", github: "jekyll/minima"
gem "jekyll-archives", "2.2.1"

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "1.2.6"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.0", :install_if => Gem.win_platform?

