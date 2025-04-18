module Errors
  class AlreadySubmitted < StandardError
  end

  class AlreadyReturned < StandardError
  end

  class AlreadyCompleted < StandardError
  end

  class AlreadyMarkedAsReady < StandardError
  end

  class DocumentUploadError < StandardError
  end

  class NotValidForMAAT < StandardError
  end

  class AlreadyArchived < StandardError
  end

  class CannotArchive < StandardError
  end
end
