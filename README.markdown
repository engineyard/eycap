# eycap

## Description

The Engine Yard capistrano tasks are for use specifically with Engine Yard Managed.  They include convenience methods for managed a database, mongrel, nginx or other services.

## Requirements

* capistrano (http://capify.org) > 2.0.0, but recommended with > 2.2.0

* NOTE: If you're using a git repository we recommend capistrano 2.5.3 and greater.

## Install

    $ gem install eycap      # installs the latest eycap version

## Usage

Your deploy.rb file is provided for you when you are setup by our engineers.  In order to deploy you'll need to do the normal capistrano steps to "capify" your site.  But you'll replace the auto-generated deploy.rb file with the one Engine Yard provides.

From there you'll be able to deploy to your staged environment like so:

    $ cap production deploy

For a list of all available commands, run:

    $ cap -T

## Pull Requests
 
If you'd like to contribute to the eycap gem please create a fork, then send a pull request and a member of the eycap team will review it.

## Issues

When you run into a problem please check the issues to see if one has been reported.  If not, please report the issue and we'll get to work on fixing it. 

## License

Copyright (c) 2008-2012 Engine Yard

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