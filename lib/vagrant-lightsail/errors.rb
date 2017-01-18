require 'vagrant'

module VagrantPlugins
  module Lightsail
    class VagrantLightsailError < Vagrant::Errors::VagrantError
      error_namespace('vagrant_lightsail.errors')
    end

    class LightsailError < VagrantLightsailError
      error_key(:lightsail_error)
    end

    class PublicKeyError < DigitalOceanError
      error_key(:public_key)
    end
  end
end
