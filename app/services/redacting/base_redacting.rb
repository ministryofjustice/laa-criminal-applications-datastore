module Redacting
  class BaseRedacting
    include Rules

    def initialize(record)
      @record = record
    end

    # :nocov:
    def process!
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    attr_reader :record

    # Creates a deep nested hash out of an array of keys
    # ['a', 'b', 'c'] => { 'a' => { 'b' => { 'c' => details } } }
    def traverse(path, details)
      path.reverse.inject(details) { |value, key| { key => value } }
    end

    def exposed_payload
      record.submitted_application
    end

    def protected_payload
      secure_store.protected_details
    end

    def secure_store
      @secure_store ||= (record.personally_identifiable_details || record.build_personally_identifiable_details)
    end
  end
end
