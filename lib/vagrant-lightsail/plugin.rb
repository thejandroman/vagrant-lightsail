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
        setup_i18n
        require_relative 'provider'
        Provider
      end

      # This initializes the internationalization strings.
      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', Lightsail.source_root)
        I18n.reload!
      end
    end
  end
end
