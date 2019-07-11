# Browsed

Browsed is a wrapper around Capybara/Selenium with tools for proxy management and utilities for randomizing user agents, resolutions etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'browsed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install browsed

## Usage

```ruby
# browser can be: :chrome, :firefox or :phantomjs (PhantomJS might be deprecated eventually though)
# device can be :desktop, :phone (iphone/android), :tablet (ipad/android), :iphone, :ipad, :android_phone, :android_tablet
client    =   Browsed::Client.new(browser: :chrome, headless: false, device: :desktop)
client.session.visit "https://www.google.com"
```

Proxy auth support is supported using two different methods:

1) For non-headless Google Chrome a plugin will be generated on the fly and used by Chrome to auto-fill username/password for the proxy. Major downside with this approach is that Chrome can't be run in headless mode.

2) Using the NodeJS library proxy-chain. Browsed will spawn a Node sub-process that will run a local proxy server that forwards all packets to the final proxy server. When the client is finished (by issuing client.quit!) the proxy-chain server will also be terminated. Major downside: depends on Node being installed.

Here's an example using a proxy via proxy-chain:

```ruby
proxy     =   {host: "127.0.0.1", port: 8080, username: "foo", password: "bar", mode: :proxy_chain}
client    =   Browsed::Client.new(browser: :chrome, headless: false, device: :desktop, proxy: proxy)
client.session.visit "https://www.google.com"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SebastianJ/browsed. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Browsed project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/SebastianJ/browsed/blob/master/CODE_OF_CONDUCT.md).
