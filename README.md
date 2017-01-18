# Lightsail Vagrant Provider

`vagrant-lightsail` is a [Vagrant](https://www.vagrantup.com/) 1.2+
plugin that support managing [Lightsail](https://amazonlightsail.com/)
instances.

It can:
- Create and destroy instances
- Power on and off instances
- Provision an instance
- Setup an SSH public key for authentication

It is based heavily
on [vagrant-aws](https://github.com/mitchellh/vagrant-aws)
and
[vagrant-digitalocean](https://github.com/devopsgroup-io/vagrant-digitalocean).

## Install

Install the provider plugin using the Vagrant command-line interface:

`vagrant plugin install vagrant-lightsail`

## Quick Start

After installing the plugin, specify all the details within the
`config.vm.provider` block in your Vagrantfile.

```
Vagrant.configure('2') do |config|
  config.ssh.private_key_path = 'PATH TO YOUR PRIVATE KEY'
  config.ssh.username         = 'ubuntu'
  config.vm.box               = 'lightsail'
  config.vm.box_url           = 'https://github.com/thejandroman/vagrant-lightsail/raw/master/box/lightsail.box'

  config.vm.provider :lightsail do |provider, override|
    provider.access_key_id     = 'YOUR KEY'
    provider.secret_access_key = 'YOUR SECRET KEY'
    provider.keypair_name      = 'KEYPAIR NAME'
  end
end
```

And then run `vagrant up`.

This will start an Ubuntu instance in the us-east-1a availability zone
within your account.

**Note:** if you don't configure `provider.access_key_id` or
`provider.secret_access_key` it will attempt to read credentials from
environment variables first and then from `$HOME/.aws/`. You can
choose your AWS profile and files location by using
`provider.aws_profile` and `provider.aws_dir`, however environment
variables will always have precedence as defined by
the
[AWS documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
To use profile `vagrantDev` from your AWS files:

 ```ruby
provider.aws_dir = ENV['HOME'] + "/.aws/"
provider.aws_profile = "vagrantDev"
 ```

## Configuration

The following attributes are available to configure the provider:

- `access_key_id`
  * The access key for accessing AWS
- `availability_zone`
  * The availability zone within the region to launch the instance. If
    nil, it will append `a` to the region.
- `aws_dir`
  * AWS config and credentials location. Defaults to *$HOME/.aws/*.
- `aws_profile`
  * AWS profile in your config files. Defaults to *default*.
- `blueprint_id`
  * The ID for a virtual private server image. Defaults to *ubuntu_16_04*.
- `bundle_id`
  * The bundle of specification information for the instance,
    including the pricing plan. Defaults to *nano_1_0*.
- `endpoint`
  * A regional endpoint.
- `keypair_name`
  * The name to use when creating an SSH key for
    authentication. Defaults to *vagrant*.
- `region`
  * The region to start the instance in. Defaults to *us-east-1*.
- `secret_access_key`
  * The secret access key for accessing AWS.
- `session_token`
  * The session token provided by STS.
- `user_data`
  * Plain text user data for the instance being booted.

## Contributing

- Fork and clone repo
- Install bundler
```
gem install bundler -v 1.12.5
```
- Install dependencies
```
bundle install
```
- Run tests
```
bundle exec rake test
```
- Make code changes
- Run tests again
- Update *README.md* and *CHANGELOG.md*
- Create a Pull Request!

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
