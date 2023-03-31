module Errors
  class AlreadyReturned < StandardError
  end

  class AlreadyCompleted < StandardError
  end

  class AlreadyMarkedAsReady < StandardError
  end
end
