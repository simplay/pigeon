# A SimpleAction defines an action without arguments
class SimpleAction < Action
  def initialize
    super { run } 
  end
end
