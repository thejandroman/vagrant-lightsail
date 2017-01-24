require 'iniparse'

module VagrantPlugins
  module Lightsail
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :access_key_id
      attr_accessor :availability_zone
      attr_accessor :aws_dir
      attr_accessor :aws_profile
      attr_accessor :blueprint_id
      attr_accessor :bundle_id
      attr_accessor :endpoint
      attr_accessor :keypair_name
      attr_accessor :port_info
      attr_accessor :region
      attr_accessor :secret_access_key
      attr_accessor :session_token
      attr_accessor :user_data

      def initialize
        @access_key_id     = UNSET_VALUE
        @availability_zone = UNSET_VALUE
        @aws_dir           = UNSET_VALUE
        @aws_profile       = UNSET_VALUE
        @blueprint_id      = UNSET_VALUE
        @bundle_id         = UNSET_VALUE
        @endpoint          = UNSET_VALUE
        @keypair_name      = UNSET_VALUE
        @port_info         = [UNSET_VALUE]
        @region            = UNSET_VALUE
        @secret_access_key = UNSET_VALUE
        @session_token     = UNSET_VALUE
        @user_data         = UNSET_VALUE
      end

      def finalize!
        if @access_key_id == UNSET_VALUE || @secret_access_key == UNSET_VALUE
          @aws_profile = 'default'                   if @aws_profile == UNSET_VALUE
          @aws_dir     = ENV['HOME'].to_s + '/.aws/' if @aws_dir == UNSET_VALUE

          @aws_region, @access_key_id, @secret_access_key, @session_token = Credentials.new.get_aws_info(@aws_profile, @aws_dir)
          @region = @aws_region if @region == UNSET_VALUE && !@aws_region.nil?
        else
          @aws_profile = nil
          @aws_dir     = nil
        end

        @blueprint_id      = 'ubuntu_16_04' if @blueprint_id      == UNSET_VALUE
        @bundle_id         = 'nano_1_0'     if @bundle_id         == UNSET_VALUE
        @endpoint          = nil            if @endpoint          == UNSET_VALUE
        @keypair_name      = 'vagrant'      if @keypair_name      == UNSET_VALUE
        @port_info         = []             if @port_info         == [UNSET_VALUE]
        @region            = 'us-east-1'    if @region            == UNSET_VALUE
        @availability_zone = "#{@region}a"  if @availability_zone == UNSET_VALUE
        @session_token     = nil            if @session_token     == UNSET_VALUE
        @user_data         = nil            if @user_data         == UNSET_VALUE
      end

      def validate(_)
        errors = []

        if @aws_profile && (@access_key_id.nil? || @secret_access_key.nil? || @region.nil?)
          errors << I18n.t('vagrant_lightsail.config.aws_info_required',
                           profile: @aws_profile, location: @aws_dir)
        end

        errors << I18n.t('vagrant_lightsail.config.port_info_array') unless @port_info.is_a? Array

        errors << I18n.t('vagrant_lightsail.config.region_required') if @region.nil?

        { 'Lightsail Provider' => errors }
      end
    end

    class Credentials < Vagrant.plugin('2', :config)
      def get_aws_info(profile, location)
        aws_region, aws_id, aws_secret, aws_token = read_aws_environment

        if aws_id.to_s.empty? || aws_secret.to_s.empty?
          aws_config = ENV['AWS_CONFIG_FILE'].to_s
          aws_creds  = ENV['AWS_SHARED_CREDENTIALS_FILE'].to_s

          if aws_config.empty? || aws_creds.empty?
            aws_config = location + 'config'
            aws_creds  = location + 'credentials'
          end

          if File.exist?(aws_config) && File.exist?(aws_creds)
            aws_region, aws_id, aws_secret, aws_token = read_aws_files(profile, aws_config, aws_creds)
          end

        end

        aws_region = nil if aws_region == ''
        aws_id     = nil if aws_id     == ''
        aws_secret = nil if aws_secret == ''
        aws_token  = nil if aws_token  == ''

        [aws_region, aws_id, aws_secret, aws_token]
      end

      private

      def read_aws_files(profile, aws_config, aws_creds)
        conf_profile = profile == 'default' ? profile : 'profile ' + profile

        data_conf   = File.read(aws_config)
        doc_conf    = IniParse.parse(data_conf)
        aws_region  = doc_conf[conf_profile]['region']

        data_cred  = File.read(aws_creds)
        doc_cred   = IniParse.parse(data_cred)
        aws_id     = doc_cred[profile]['aws_access_key_id']
        aws_secret = doc_cred[profile]['aws_secret_access_key']
        aws_token  = doc_cred[profile]['aws_session_token']

        [aws_region, aws_id, aws_secret, aws_token]
      end

      def read_aws_environment
        aws_region = ENV['AWS_DEFAULT_REGION']
        aws_id     = ENV['AWS_ACCESS_KEY_ID']
        aws_secret = ENV['AWS_SECRET_ACCESS_KEY']
        aws_token  = ENV['AWS_SESSION_TOKEN']

        [aws_region, aws_id, aws_secret, aws_token]
      end
    end
  end
end
