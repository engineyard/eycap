# eycap [![Build Status](https://secure.travis-ci.org/engineyard/eycap.png)](http://travis-ci.org/engineyard/eycap)

## Description

The Engine Yard capistrano tasks are for use specifically with Engine Yard Managed services.  But can be used as examples for building other tasks as well.

## Requirements

* [Capistrano](https://github.com/capistrano/capistrano) >= 2.2.0

* NOTE: When using a git repository use Capistrano >= 2.5.3.

## Install

Use your `Gemfile` and `bundler` to both document and install the `eycap` gem to your application.  We also recommend the following gems to be configured along side `eycap`.  Add these to your `Gemfile`:

```ruby
group :development, :test do
  gem 'eycap', :require => false
  gem 'capistrano', '~> 2.15'
  gem 'net-ssh', '~> 2.7.0'
end
```

Then run bundle install to install the `eycap` and other gem(s).

    $ bundle install

Then in your `deploy.rb` file you'll need to add the following require statement to the begininng of the file:

```
require "eycap/recipes"
```

## Usage

### Configuration

Your initial deploy.rb will be provided for you when your servers are provisioned on Engine Yard Managed.  In order to deploy your application, you can go to the `RAILS_ROOT` folder and run:

    $ capify .

This generates the `Capfile` and the `config/deploy.rb` file for you.  You'll replace the `config/deploy.rb` file with the `deploy.rb` given to you by Engine Yard.

For deploying Rails 3.1 or greater apps using the [asset pipeline](https://github.com/engineyard/eycap/wiki/Asset-Pipeline) read more on the linked page.

### Setup restart server

Mongrel is the default server, to override this default you'll need to define the following in your `deploy.rb` file:

```ruby
namespace :deploy do

  task :restart, :roles => :app do
    # mongrel.restart
  end


  task :spinner, :roles => :app do
    # mongrel.start
  end


  task :start, :roles => :app do
    # mongrel.start
  end    
  

  task :stop, :roles => :app do
    # mongrel.stop
  end
  
end
```

Replace the commented out with your server (passenger, unicorn, thin, puma, etc.) and then it will override the default of mongrel.

### Deploying to Environment

To ensure your environments are ready to deploy, check on staging.

    $ cap staging deploy:check

This will determine if all requirements are met to deploy.  Sometimes if the default folders are not setup you may be able to repair by running:

    $ cap staging deploy:setup

If you cannot get `deploy:check` to pass, please open a [new support ticket](https://support.cloud.engineyard.com/tickets/new) and let us know.

Now you're ready to do a test deploy.

Optionally, `cap deploy:cold` will run your migrations and start (instead of restart) your app server.

    $ cap staging deploy:cold

Or if you have already dumped a copy of your data to staging or do not want to run migrations you can simply do a deploy.

    $ cap staging deploy

And to do all this on production, just change the environment name and you'll be all set.

    $ cap production deploy

## Eycap Commands

For a list of all available commands, run:

    $ cap -T

This will show you not only the default capistrano commands but also the ones you get by including the eycap gem.

## Custom binaries path

In rare cases (`unicorn` / `sphinx`) it is required to set custom path for binaries when using
development versions of scripts. It is as easy as:

```ruby
set :engineyard_bin, "/engineyard/custom"
```

The default is `/engineyard/bin` and is just fine in normal deployment.

## Pull Requests

If you'd like to contribute to the eycap gem please create a fork, then send a pull request and a member of the eycap team will review it.

## Issues

When you run into a problem please check the [issues](/issues) to see if one has been reported.  If not, please report the issue and we'll get to work on fixing it.

## License

Copyright (c) Engine Yard

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
