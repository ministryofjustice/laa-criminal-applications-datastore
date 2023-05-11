module Utils
  class OffenceClassCalculator
    attr_reader :offences

    def initialize(offences:)
      @offences = offences
    end

    def offence_class
      if any_manually_entered_offences? || any_multi_class_offences?
        nil
      else
        highest_ranking_offence_class
      end
    end

    private

    def highest_ranking_offence_class
      rank_offences.first
    end

    def rank_offences
      offences_classes = offences.pluck('offence_class')
      offences_classes.sort_by { |oc| Types::OffenceClass.values.index oc }
    end

    def any_manually_entered_offences?
      offences.any? { |o| o.fetch('offence_class').nil? }
    end

    def any_multi_class_offences?
      offences.any? { |o| o.fetch('offence_class').length > 1 }
    end
  end
end
