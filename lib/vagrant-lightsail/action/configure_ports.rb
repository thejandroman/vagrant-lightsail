require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This configures ports on instance
      class ConfigurePorts
        def initialize(app, _)
          @app = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::configure_ports')
        end

        def call(env)
          port_info = env[:machine].provider_config.port_info

          port_info.each do |pi|
            env[:lightsail_client].open_instance_public_ports(
              port_info: pi,
              instance_name: env[:machine].id
            )

            env[:ui].info I18n.t 'vagrant_lightsail.port_open',
                                 proto: pi[:protocol],
                                 port_no_from: pi[:from_port],
                                 port_no_to: pi[:to_port]
          rescue Aws::Lightsail::Errors::InvalidInputException => e
            env[:ui].info I18n.t 'vagrant_lightsail.port_open_fail',
                                 proto: pi[:protocol],
                                 port_no_from: pi[:from_port],
                                 port_no_to: pi[:to_port],
                                 error: e.to_s
          rescue Aws::Lightsail::Errors => e
            raise Errors::LightailError, message: e
          end

          @app.call(env)
        end
      end
    end
  end
end
