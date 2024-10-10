module Transformer
  class MAAT
    PERSON_RULES = {
      'first_name' => 40,
      'last_name' => 40,
      'other_names' => 40,
      'telephone_number' => 20,
      'nino' => 10,
    }.freeze

    ADDRESS_RULES = {
      'lookup_id' => 10,
      'address_line_one' => 100,
      'address_line_two' => 100,
      'city' => 100,
      'postcode' => 10,
      'country' => 150,
    }.freeze

    URN_RULES = {
      'urn' => 50,
    }.freeze

    PROVIDER_DETAILS_RULES = {
      'office_code' => 6,
      'provider_email' => 255,
      '_calculation' => lambda do |hash|
        full_name = "#{hash['legal_rep_first_name']} #{hash['legal_rep_last_name']}"

        # Maintain last name as much as possible
        if full_name.size > 40
          hash['legal_rep_last_name'] = hash['legal_rep_last_name'].truncate(38, omission: '...')
          hash['legal_rep_first_name'] = hash['legal_rep_first_name'][0]
        end

        hash
      end
    }.freeze

    PROPERTY_OWNER_RULES = {
      'name' => 255,
      'other_relationship' => 255,
    }.freeze

    PAYMENT_DETAILS_RULES = 1000

    class << self
      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
      # Cuts a given string value or set of values does to the specified limit. Works with
      # Hashes of key/value pairs or individual strings. Only chops string values, leaving
      # non-string values alone. If obj is a Hash, only matching keys defined in criteria will result
      # in the obj value being chopped.
      #
      # Allows calculations through the use of the `_calculation` special
      # criteria key value
      #
      # @param obj [Hash|String] the value or values collection to truncate
      # @param criteria [Hash|Integer] the set of limits with keys corresponding to obj or a single integer
      # @return [Hash|String] the original object will be changed!
      def chop!(obj, criteria = nil)
        return obj if obj.nil? || criteria.nil?

        if obj.is_a?(String)
          obj = truncate!(obj, criteria)
        elsif obj.is_a?(Hash)
          obj.each do |k, v|
            next if v.blank?
            next unless v.is_a?(String)
            next if criteria.is_a?(Hash) && !criteria.key?(k)

            length = criteria.is_a?(Hash) ? criteria[k] : criteria

            obj[k] = v.to_s.truncate(length, omission: '...')
          end

          # Run through any calculations (lambda)
          obj = calculate!(obj, criteria)
        end

        obj
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

      def truncate!(str, length)
        str.truncate(length, omission: '...')
      end

      def calculate!(obj, criteria)
        return obj unless criteria.is_a?(Hash) && criteria.key?('_calculation')

        criteria['_calculation'].call(obj)
      end
    end
  end
end
