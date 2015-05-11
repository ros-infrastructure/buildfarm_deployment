Puppet Module for Upstart
=========================

This module manages Upstart job configurations and the resulting
services. It includes support for enabling Upstart's per-user jobs.

Basic Usage
-----------

    class { 'upstart':
      user_jobs => true,
    }

Or simply:

    include upstart

Creating a job and enabline the service
---------------------------------------

    upstart::job { 'test_service':
      description    => "This is an example upstart service",
      version        => "3626f2",
      respawn        => true,
      respawn_limit  => '5 10',
      user           => 'app-user',
      group          => 'app-user',
      chdir          => '/path/to/app',
      exec           => "start.sh",
    }

Dependencies
------------

- [stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

Copyright and License
---------------------

Copyright (C) 2012 Brad Ison

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
