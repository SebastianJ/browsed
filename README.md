# Browsed

Browsed is a lightweight Capybara/PhantomJS/Selenium framework with tools and utilities for randomizing user agents, resolutions etc.

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
# driver can be :poltergeist (PhantomJS) or :selenium/:selenium_chrome/:selenium_chrome_headless (Firefox/Chrome)
# browser can be: :phantomjs, :chrome, :chrome_headless, :firefox, :firefox_headless
# device can be :desktop, :phone (iphone/android), :tablet (ipad/android), :iphone, :ipad, :android_phone, :android_tablet
client    =   Browsed::Client.new(driver: :selenium_chrome, browser: :chrome, device: :desktop)
```

If you want to use proxies (note that proxy authentication is only possible using Poltergeist/PhantomJS):

```ruby
proxy     =   {host: "127.0.0.1", port: 8080, username: "foo", password: "bar"}
client    =   Browsed::Client.new(driver: :poltergeist, browser: :phantomjs, device: :desktop, proxy: proxy)
```

Use the session property to interact with the underlying Capybara::Session object:

```ruby
client.session.visit("https://www.google.com")
```

## Support

Proxy authentication is currently only supported by PhantomJS and Chrome not running in headless mode.

Chrome proxy authentication support is somewhat of a hack and works by dynamically generating a plugin on the fly and then starting Chrome with that plugin. Unfortunately this doesn't work in headless Chrome.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SebastianJ/browsed. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Browsed project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/SebastianJ/browsed/blob/master/CODE_OF_CONDUCT.md).
