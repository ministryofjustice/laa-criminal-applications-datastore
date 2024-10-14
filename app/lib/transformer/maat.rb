module Transformer
  module MAAT
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

    PROVIDER_DETAILS_RULES = {
      'office_code' => 6,
      'provider_email' => 255,
      '_calculation' => lambda do |hash|
        full_name = "#{hash['legal_rep_first_name']} #{hash['legal_rep_last_name']}"

        # Maintain last name as much as possible
        if full_name.size > 40
          hash['legal_rep_last_name'] = truncate!(hash['legal_rep_last_name'], 38)
          hash['legal_rep_first_name'] = hash['legal_rep_first_name'][0]
        end

        hash
      end
    }.freeze

    # Key should match name of Grape Entity or key name
    RULES = {
      'client_details' => {
        'applicant' => {
          'home_address' => ADDRESS_RULES,
          'correspondence_address' => ADDRESS_RULES,
        }.merge(PERSON_RULES),
        'partner' => PERSON_RULES,
      },
      'property' => {
        'address' => ADDRESS_RULES,
      },
      'property_owner' => {
        'name' => 255,
        'other_relationship' => 255,
      },
      'case_details' => {
        'urn' => 50,
      },
      'provider_details' => PROVIDER_DETAILS_RULES,
      'payment' => {
        'details' => 1000,
      },
    }.freeze

    # Assumes module is being used by a Grape::Entity or a Hash.
    # Offers a consistent way of truncating an Application via localised
    # Grape::Entity objects or from top-level Application.
    # TODO: Make method recursively chop! data in key/value pairs by (pattern) matching
    # against RULES
    #
    # @param obj [Hash|String] the key name of the Grape::Entity to extract or a Hash of key/values
    # @param fallback [String|Array] if Grape::Entity key value is nil, use the fallback instead
    # @param rule [String|Array] the hash key name from RULES to use (or list of key names if nested RULE)
    # @return [Hash|String] the original object will be changed!
    def transform!(obj, fallback: nil, rule: [])
      return nil if obj.nil?

      rule_path = obj.is_a?(Hash) ? [rule] : [*rule, obj].compact
      rules = RULES.dig(*rule_path.flatten)

      if obj.is_a?(Hash)
        Transformer::MAAT.chop!(obj, rules)
      else
        str = object[obj] || object.dig(*[fallback].flatten)
        Transformer::MAAT.chop!(str, rules)
      end
    end

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

        case obj
        when String
          length = criteria.is_a?(Hash) ? criteria[obj] : criteria

          obj = truncate!(obj, length)
        when Hash
          obj.each do |k, v|
            next if v.blank?
            next unless v.is_a?(String)
            next if criteria.is_a?(Hash) && !criteria.key?(k)

            length = criteria.is_a?(Hash) ? criteria[k] : criteria
            obj[k] = truncate!(v, length)
          end

          obj = calculate!(obj, criteria)
        end

        obj
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

      def truncate!(str, length)
        return str if length.blank?

        str.to_s.truncate(length, omission: '...')
      end

      def calculate!(obj, criteria)
        return obj unless criteria.is_a?(Hash) && criteria.key?('_calculation')

        criteria['_calculation'].call(obj)
      end
    end
  end
end
