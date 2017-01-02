require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_aws::action::read_ssh_info')
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:lightsail_client],
                                                 env[:machine])
          @app.call(env)
        end

        def read_ssh_info(lightsail, machine)
          return nil if machine.id.nil?

          begin
            # Find the machine
            server = lightsail.get_instance(instance_name: machine.id)
          rescue Aws::Lightsail::Errors::NotFoundException
            # The machine can't be found
            @logger.info('Machine could not be found, assuming it got destroyed.')
            machine.id = nil
            return nil
          end

          { host: server.instance.public_ip_address, port: 22 }
        end
      end
    end
  end
end
