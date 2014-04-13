# Supervision
[![Gem Version](https://badge.fury.io/rb/supervision.png)][gem]
[![Build Status](https://secure.travis-ci.org/peter-murach/supervision.png?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/peter-murach/supervision.png)][codeclimate]

[gem]: http://badge.fury.io/rb/supervision
[travis]: http://travis-ci.org/peter-murach/supervision
[codeclimate]: https://codeclimate.com/github/peter-murach/supervision

Write distributed systems that are resilient and self-heal. Remote calls can fail or hang indefinietly without a response.
**Supervision** will help to isolate failure and keep individual components from bringing down the whole system.
The basic idea is to wrap dangerous method call inside protected `supervise` helper that will monitor for failure and
handle it according to the specified rules to prevent it from cascading.

## Installation

Add this line to your application's Gemfile:

    gem 'supervision'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install supervision

## 1 Usage

**Supervision** instance takes the following configuration options:

* `:max_failure` - maximum failure count allowed before **Supervision** raises `CircuitBreakerOpenError`. By default `5 failures` are allowed.
* `:call_timeout` -  duration time for a method before it is assumed to have failed. By default `10 milliseconds`.
* `:reset_timeout` - duration before a method is allowed to attempt a call. Subsequent calls will fail fast if failure is detected. By default `100 milliseconds`

Next to instantiate the **Supervision** in order to protect a call to external/remote service that has potential to fail do:

```ruby
@supervision = Supervision.new { |arg| remote_api_call(arg) }
```

or alternatively use `supervise` helper

```ruby
@supervision = Supervision.supervise { |arg| remote_api_call(arg) }
```

Once the call is wrapped you can execute it by sending `call` messsage with arguments like so:

```ruby
@supervision.call({user: 'Piotr'})
```

Finally, you can also register **Supervision** instance by name

```ruby
Supervision.supervise_as(:danger) { remote_api_call }
```

The name under which method is registerd will be available as a method call

```ruby
Supervision.danger.call
```

## 2 Mixin

**Supervision** can also act as a mixin and expose `supervise` and `supervise_as` accordingly.

```ruby
class Api
  include Supervision

  def remote_call
    ...
  end
  supervise :danger { remote_call }

  def fetch(repository)
    danger.call(repository)
  rescue Supervision::CircuitBreakerOpenError
    nil
  end
end

@api = Api.new
@api.fetch('github_api')
```

## 3 Callbacks

You can listen for `failure` and `success` by attaching `on_failure`, `on_success` listeners respectively:

```ruby
@supervision.on_failure { notify_me }

def notify_me
  puts("The circuit breaker is now open")
end
```

## 4 Configuration

If you want to configure **Supervision**, you can either pass options directly

```ruby
@supervision = Supervison.new max_failures: 2, call_timeout: 10.milli, reset_timeout: 0.1.sec do
  remote_api_call
end
```

or use `configure` helper

```ruby
@supervision.configure do
  max_failures  5
  call_timeout  10.sec
  reset_timeout 1.min
end
```

## 5 Time

All the numeric types are extended with time related helpers to allow for more fluid parameters when creating **Supervision**

```ruby
call_timeout: 10.milliseconds
call_timeout: 10.millis
call_timeout: 1.millisecond
call_timeout: 1.milli
call_timeout: 1.second
call_timeout: 1.sec
call_timeout: 10.secs
call_timeout: 10.seconds
call_timeout: 1.minute
call_timeout: 1.min
call_timeout: 10.minutes
call_timeout: 10.mins
call_timeout: 1.hour
call_timeout: 10.hours
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/supervision/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2014 Piotr Murach. See LICENSE for further details.
