module Boson
  # Collection of utility methods used throughout Boson.
  module Util
    extend self
    # From Rails ActiveSupport, converts a camelcased string to an underscored string:
    # 'Boson::MethodInspector' -> 'boson/method_inspector'
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
       gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
       gsub(/([a-z\d])([A-Z])/,'\1_\2').
       tr("-", "_").
       downcase
    end

    # From Rails ActiveSupport, does the reverse of underscore:
    # 'boson/method_inspector' -> 'Boson::MethodInspector'
    def camelize(string)
      string.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end

    # Converts a module/class string to the actual constant.
    # Returns nil if not found.
    def constantize(string)
      any_const_get(camelize(string))
    end

    def symbolize_keys(hash)
      hash.inject({}) {|options, (key, value)|
        options[key.to_sym] = value; options
      }
    end

    # Returns a constant like const_get() no matter what namespace it's nested in.
    # Returns nil if the constant is not found.
    def any_const_get(name)
      return name if name.is_a?(Module)
      begin
        klass = Object
        name.split('::').each {|e|
          klass = klass.const_get(e)
        }
        klass
      rescue
         nil
      end
    end

    # Detects new object/kernel methods, gems and modules created within a block.
    # Returns a hash of what's detected.
    # Valid options and possible returned keys are :methods, :object_methods, :modules, :gems.
    def detect(options={}, &block)
      options = {:methods=>true, :object_methods=>true}.merge!(options)
      original_gems = Gem.loaded_specs.keys if Object.const_defined? :Gem
      original_object_methods = Object.instance_methods
      original_instance_methods = class << Boson.main_object; instance_methods end
      original_modules = modules if options[:modules]
      block.call
      detected = {}
      detected[:methods] = options[:methods] ? (class << Boson.main_object; instance_methods end -
        original_instance_methods) : []
      detected[:methods] -= (Object.instance_methods - original_object_methods) unless options[:object_methods]
      detected[:gems] = Gem.loaded_specs.keys - original_gems if Object.const_defined? :Gem
      detected[:modules] = modules - original_modules if options[:modules]
      detected
    end

    # Safely calls require, returning false if LoadError occurs.
    def safe_require(lib)
      begin
        require lib
      rescue LoadError
        false
      end
    end

    # Returns all modules that currently exist.
    def modules
      all_modules = []
      ObjectSpace.each_object(Module) {|e| all_modules << e}
      all_modules
    end

    # Returns array of _all_ common instance methods between two modules/classes.
    def common_instance_methods(module1, module2)
      (module1.instance_methods + module1.private_instance_methods) & (module2.instance_methods + module2.private_instance_methods)
    end

    # Creates a module under a given base module and possible name. If the module already exists, it attempts
    # to create one with a number appended to the name.
    def create_module(base_module, name)
      desired_class = camelize(name)
      possible_suffixes = [''] + %w{1 2 3 4 5 6 7 8 9 10}
      if (suffix = possible_suffixes.find {|e| !base_module.const_defined?(desired_class+e)})
        base_module.const_set(desired_class+suffix, Module.new)
      end
    end

    # Behaves just like the unix which command, returning the full path to an executable based on ENV['PATH'].
    def which(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).map {|e| File.join(e, command) }.find {|e| File.exists?(e) }
    end

    # Deep copies any object if it can be marshaled. Useful for deep hashes.
    def deep_copy(obj)
      Marshal::load(Marshal::dump(obj))
    end

    # Recursively merge hash1 with hash2.
    def recursive_hash_merge(hash1, hash2)
      hash1.merge(hash2) {|k,o,n| (o.is_a?(Hash)) ? recursive_hash_merge(o,n) : n}
    end

    # From Rubygems, determine a user's home.
    def find_home
      ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
      return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      File.expand_path("~")
    rescue
      File::ALT_SEPARATOR ? "C:/" : "/"
    end
  end
end
