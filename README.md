BackInMotion
============

This library allows you to call back RubyMotion from your Objective-C application.

It's expected to be used alongside with ruby code compiled by `rake static`.

Usage
-----

You can access ruby's `Object#const_get` via `+[BackInMotion const_get:]`.
The returned object is wrapped in a proxy class, that should allow you to
call any ruby method the same way you do in with Objective-C (under the
hood it dispatches the call through `vm_dispatch` of MacRuby).

Should you require access to original non-wrapped object, you can get it
from proxy with `__rubyObject` method.

License
-------

The code is licensed under MIT. The MacRuby code is licensed under the Ruby license.