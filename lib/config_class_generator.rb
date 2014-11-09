# encoding utf-8

class ConfigClassGenerator
  class Config
    def initialize
      @setting = {}
    end

    ##
    # |name Symbol
    # => object(&nil) | nil
    def [] name
      fetch name rescue nil
    end

    ##
    # |name Symbol
    # => object(&nil) | error
    def fetch name
      name = name.intern
      if @setting.key? name
        @setting[name]
      elsif @@default.key? name
        @@default[name]
      else
        raise KeyError, "key not found: #{name}"
      end
    end
  end

  attr_reader :name, :klass

  ##
  # @default {Symbol => object(&nil)}
  # @arity {Symbol => <def ===(Integer)>}
  # @name String
  def initialize name
    @klass = Class.new(Config)
    @default = {}
    @klass.class_variable_set :@@default, @default
    @arity = {}
    @klass.class_variable_set :@@arity, @arity
    @name = name.freeze
    @@configs ||= {}
    @@configs[@name] = self
  end

  WillNotSet = Object.new
  def will_set? x
    x != WillNotSet
  end
  private :will_set?

  ##
  # |name Symbol
  # |arity:? <def ===(Integer)> | :zero_or_more | :one_or_more
  # |default:? object(&nil) | WillNotSet
  # => void
  def add_config name, arity: 1, default: WillNotSet
    name = name.intern
    @default[name] = default if will_set? default
    @arity[name] =
      case arity
        when :zero_or_more then (0..Float::Infinity)
        when :one_or_more  then (1..Float::Infinity)
        else arity
      end
    arity = @klass.class_variable_get :@@arity
    @klass.__send__ :define_method, name, &->(*vals) do
      if arity[name] === vals.length
        @setting[name] = vals
      else
        raise ArgumentError, "wrong number of arguments (#{vals.length} for #{arity[name]})"
      end
    end
  end

  def self.configure name, &b
    c = class_variable_get(:@@configs).fetch(name).klass.new
    c.instance_eval &b
    c
  end

  def self.load filename
    class_eval File.read filename
  end
end
