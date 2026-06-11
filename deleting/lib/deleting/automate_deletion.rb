module Deleting
  class AutomateDeletion
    def self.call # rubocop:disable Metrics/MethodLength
      Rails.logger.info('Start of automated deletion')

      DeletableEntity.expired.each do |deletable_entity|
        business_reference = deletable_entity.business_reference

        Commands::SyncMAATRecord.new(
          business_reference:
        ).call

        Commands::Delete.new(
          business_reference: business_reference,
          reason: Types::DeletionReason['retention_rule'],
          deleted_by: 'system_automated'
        ).call
      end

      Rails.logger.info('End of automated deletion task')
    end
  end
end
