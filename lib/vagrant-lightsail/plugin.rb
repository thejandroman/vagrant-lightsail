module VagrantPlugins
  module Lightsail
    class Plugin < Vagrant.plugin('2')
      name 'Lightsail'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines in AWS Lightsail.
      DESC

      config(:lightsail, :provider) do
        require_relative 'config'
        Config
      end

      provider(:lightsail, parallel: true) do
        require_relative 'provider'
        Provider
      end
    end
  end
end
