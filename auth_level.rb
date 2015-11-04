module AuthLevel
  class Initializer
    def initialize(*args)
      @level = 3
    end
  end

  def included?(klass)
    klass.prepend Initializer
  end
  LEVELS = {
    :superadmin => 0,
    :admin => 1,
    :normal => 2,
    :guest => 3
  }

  def method_missing(*arg, &block)
    if LEVELS.keys.include? arg

    else
      super(*arg, block)
    end
  end
end
