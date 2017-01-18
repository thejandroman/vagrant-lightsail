require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::read_state')
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:lightsail_client],
                                              env[:machine])
          @app.call(env)
        end

        def read_state(lightsail, machine)
          return :not_created if machine.id.nil?

          begin
            server = lightsail.get_instance_state(instance_name: machine.id)
          rescue Aws::Lightsail::Errors::NotFoundException
            return machine_not_found(machine)
          end

          if [:'shutting-down', :terminated].include? server.state.name.to_sym
            return machine_not_found(machine)
          end

          server.state.name.to_sym
        end

        private

        def machine_not_found(machine)
          @logger.info('Machine could not be found, assuming it got destroyed.')
          machine.id = nil
          :not_created
        end
      end
    end
  end
end
