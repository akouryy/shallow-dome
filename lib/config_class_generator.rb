# encoding utf-8

class ConfigClassGenerator
  class Config
    def initialize
      @setting = {}
      @@members ||= []
      @@members << self
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
  # |array:? boolean
  # |arity:? <def ===(Integer)> | :zero_or_more | :one_or_more
  # |default:? object(&nil) | WillNotSet
  # => void
  def add_config name, multi: false, arity: 1, default: WillNotSet
    name = name.intern
    @default[name] = default if will_set? default
    arity =
      case arity
        when :zero_or_more then (0..Float::Infinity)
        when :one_or_more  then (1..Float::Infinity)
        else arity
      end

    raise ArgumentError, 'arity must be 1 when not multi' if multi && arity != 1

    if multi
      @klass.__send__ :define_method, name, &->(*vals) do
        if arity === vals.length
          @setting[name] = vals
        else
          raise ArgumentError, "wrong number of arguments (#{vals.length} for #{arity[name]})"
        end
      end
    else
      @klass.__send__ :define_method, name, &->(val){ @setting[name] = val }
    end
  end

  class << self
    alias generate new

    def configure name, &b
      c = class_variable_get(:@@configs).fetch(name).klass.new
      c.instance_eval &b
    end
    private :configure

    def load filename
      class_eval File.read filename
      nil
    end

    def get name
      class_variable_get(:@@configs).fetch(name).klass.__send__ :class_variable_get, :@@members
    end

    def get_one name
      get(name)[-1]
    end
  end
end
