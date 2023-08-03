module Errors
  class AlreadyReturned < StandardError
  end

  class AlreadyCompleted < StandardError
  end

  class AlreadyMarkedAsReady < StandardError
  end

  class DocumentUploadError < StandardError
  end
end
