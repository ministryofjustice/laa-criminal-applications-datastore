module Errors
  class AlreadyArchived < StandardError; end
  class AlreadyCompleted < StandardError; end
  class AlreadyMarkedAsReady < StandardError; end
  class AlreadyReturned < StandardError; end
  class AlreadySubmitted < StandardError; end
  class CannotArchive < StandardError; end
  class NotSoftDeleted < StandardError; end
  class DocumentUploadError < StandardError; end
  class NotValidForMAAT < StandardError; end
end
