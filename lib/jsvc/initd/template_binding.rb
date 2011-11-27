module JSVC

  class Initd::MissingParamError < StandardError

    attr_reader :missing_param

    def initialize(key)
      @missing_param = key
      super("Missing parameter: #{key}")
    end

  end
  # provides a backing to the erubis template, giving some sensible defaults and combining
  # those with a set of options
  class Initd::TemplateBinding

    def initialize(options={})
      @options = options
    end

    def method_missing(method_name, *args, &block)
      result = @options[method_name] or
        begin
          def_mname = "default_#{method_name.to_s}".to_sym

          if self.respond_to?(def_mname)
            return self.send(def_mname)
          end
        end

        raise Initd::MissingParamError, method_name unless result
        result
    end

    def default_jruby_home
      @default_jruby_home ||=
        get_default_java_property("jruby.home")
    end

    def default_jsvc
      "/usr/bin/jsvc"
    end

    def default_java_home
      @default_java_home ||=
        get_default_java_property("java.home")
    end

    def default_app_path
      File.expand_path('.')
    end

    def default_script_path
      app_path + script_name + '.rb'
    end

    def default_jruby_jsvc_jar
      '/usr/share/java/jruby-jsvc.jar'
    end

    def default_commons_daemon_jar
      '/usr/share/java/commons-daemon.jar'
    end

    def default_debug
      true
    end

    def default_app_user
      script_name
    end

    def default_logging_enabled
      true
    end

    def jruby_exec
      @jruby_exec ||= `which jruby`.strip
    end

    def get_default_java_property(prop_name)
      command = "#{jruby_exec} -e 'puts Java::JavaLang::System.get_property(\"#{prop_name}\")'"
      `#{command}`
    end

    def default_pidfile
      "/var/run/#{script_name}.pid"
    end

    def get_binding
      self.send(:binding)
    end
  end
end