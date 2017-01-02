require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
  module Lightsail
    module Action
      include Vagrant::Action::Builtin

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the
      # `:machine_ssh_info` key.
      def self.read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectLightsail
          b.use ReadSSHInfo
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectLightsail, action_root.join("connect_lightsail")
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
    end
  end
end
