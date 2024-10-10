module Transformers
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

    def self.chop!(hash, rules = {})
      return nil if hash.nil?
      raise ArgumentError, 'Provide rules to use for the chop!' if rules.nil?

      hash.each do |k, v|
        next unless rules.key?(k)
        next if v.blank?

        hash[k] = v.to_s.truncate(rules[k], omission: '...')
      end

      # Run through any calculations (lambda)
      hash = rules['_calculation'].call(hash) if rules.key?('_calculation')

      hash
    end

    def self.truncate!(str, length)
      str.truncate(length, omission: '...')
    end
  end
end
