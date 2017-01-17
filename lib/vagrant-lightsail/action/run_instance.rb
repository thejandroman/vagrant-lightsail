require 'log4r'
require 'vagrant/util/retryable'

module VagrantPlugins
  module Lightsail
    module Action
      # This runs the configured instance.
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_aws::action::run_instance')
        end

        def call(env)
          # Initialize metrics if they haven't been
          env[:metrics] ||= {}

          # Get the configs

          availability_zone = env[:machine].provider_config.availability_zone
          blueprint_id      = env[:machine].provider_config.blueprint_id
          bundle_id         = env[:machine].provider_config.bundle_id
          instance_name     = env[:machine].config.vm.hostname || env[:machine].name
          keypair_name      = env[:machine].provider_config.keypair_name
          region            = env[:machine].provider_config.region
          user_data         = env[:machine].provider_config.user_data

          # If there is no keypair then warn the user
          unless keypair_name
            env[:ui].warn(I18n.t('vagrant_lightsail.launch_no_keypair'))
          end

          # Launch!
          env[:ui].info(I18n.t('vagrant_lightsail.launching_instance'))
          env[:ui].info(" -- Availability Zone: #{availability_zone}") if availability_zone
          env[:ui].info(" -- Blueprint ID: #{blueprint_id}")
          env[:ui].info(" -- Bundle ID: #{bundle_id}")
          env[:ui].info(" -- Instance Name: #{instance_name}")
          env[:ui].info(" -- Keypair: #{keypair_name}") if keypair_name
          env[:ui].info(" -- Region: #{region}")
          env[:ui].info(" -- User Data: #{user_data}") if user_data
          env[:ui].info(' -- User Data: yes') if user_data

          options = {
            availability_zone: availability_zone,
            blueprint_id:      blueprint_id,
            bundle_id:         bundle_id,
            instance_names:    [instance_name],
            key_pair_name:      keypair_name,
            user_data:         user_data
          }

          begin
            op = env[:lightsail_client].create_instances(options).operations[0]
          rescue Aws::Lightsail::Errors => e
            raise Errors::LightailError, message: e
          end

          server = env[:lightsail_client].get_instance(instance_name: instance_name).instance
          env[:machine].id = server.name

          # wait for ssh to be ready
          retryable(tries: 120, sleep: 10) do
            next if env[:interrupted]
            env[:ui].info(I18n.t('vagrant_lightsail.waiting_for_ssh'))
            raise 'not ready' unless env[:machine].communicate.ready?
          end

          env[:ui].info(I18n.t('vagrant_aws.ready'))
          env[:machine].config.ssh.username = user

          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)
          terminate(env) if env[:machine].provider.state.id != :not_created
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.destroy, destroy_env)
        end
      end
    end
  end
end
