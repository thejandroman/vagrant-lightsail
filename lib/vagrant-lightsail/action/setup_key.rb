require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This sets up the configured SSH key
      class SetupKey
        def initialize(app, _)
          @app = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::setup_key')
        end

        def call(env)
          keypair_name = env[:machine].provider_config.keypair_name

          begin
            env[:lightsail_client].get_key_pair(key_pair_name: keypair_name)
          rescue Aws::Lightsail::Errors::NotFoundException
            create_ssh_key(keypair_name, env)
          end

          @app.call(env)
        end

        private

        def create_ssh_key(name, env)
          pub_key = public_key env[:machine].config.ssh.private_key_path

          env[:ui].info I18n.t('vagrant_lightsail.info.creating_key', name: name)

          begin
            env[:lightsail_client].import_key_pair(
              key_pair_name: name,
              public_key_base_64: pub_key
            )
          rescue Aws::Lightsail::Errors => e
            raise Errors::LightailError, message: e
          end
        end

        def public_key(private_key_path)
          pub_key = if private_key_path.is_a? Array
                      Pathname.new private_key_path[0].to_s + '.pub'
                    else
                      Pathname.new private_key_path.to_s + '.pub'
                    end.expand_path
          raise Errors::PublicKeyError, path: pub_key.to_s unless pub_key.file?

          pub_key.read
        end
      end
    end
  end
end
