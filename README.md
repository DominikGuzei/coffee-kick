Coffee-Kick 
===========
A kick-start for developing CoffeeScript code and testing it with jasmine BDD / livereload

Install
=======
    bundle install

Running the tests
=================
    bundle exec rackup

then go to http://localhost:9292/SpecRunner.html

TDD cycle with guard-livereload
===============================
Coffee-Kick has guard-livereload bundled which enables auto-reloading on file changes.
You can use the [Livereload chrome extension](https://chrome.google.com/webstore/detail/jnihajbhpnppcggbcgedagnkighmdlei)

Spin up the sinatra application:

    bundle exec rackup

then go to http://localhost:9292/SpecRunner.html

Start guard-livereload by invoking:

    bundle exec guard
    
revisit http://localhost:9292/SpecRunner.html and click on the live-reload 
symbol in your browser.

Building your application
=========================

    bundle exec rake assets:build
    
you should find your concatenated application at `build/application.js`