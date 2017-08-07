## Testing

We use [Test Kitchen](http://kitchen.ci) to automatically test our automated deployments with [Serverspec](http://serverspec.org) and [RSpec](http://rspec.info/):

1) Install Test Kitchen and its dependencies from within the project's directory:

```
gem install bundler
bundle install
```

2) Run all tests

```
kitchen test
```

By default, we run our tests inside [Docker](https://www.docker.com/) containers as this considerably speeds up testing time (see `.kitchen.yml`, requires Ruby 2.2+). Alternatively, you may as well run these tests in virtual machines based on [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) (see `.kitchen.vagrant.yml`).

