module QBWC
  class Consumer
    attr_reader :integration, :config, :payload, :s3_settings

    def initialize(config = {}, payload = {})
      @config      = config
      @payload     = payload
      @integration = Persistence::Object.new config, payload
      @s3_settings = Persistence::Settings.new config
    end

    def digest_response_into_actions(response_xml)
      receive_settings = s3_settings.settings 'get_'
      params = config.merge receive: receive_settings

      send_settings = s3_settings.settings('add_')
      %w(orders shippments).each do |object_type|
        send_params = send_settings.find { |s| s[object_type] } || {}
        params = params.merge(send_params[object_type]) if send_params.key?(object_type)
      end
      Response::All.new(response_xml).process(params)
    rescue  Exception => e
      puts "Exception: digest_response_into_actions: response_xml:#{response_xml} message:#{e.message} backtrace:#{e.backtrace.inspect}"
    end
  end
end
