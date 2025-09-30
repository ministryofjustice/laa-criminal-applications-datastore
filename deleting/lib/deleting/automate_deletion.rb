module Deleting
  class AutomateDeletion
    def self.call
      Rails.logger.info('Start of automated deletion')

      DeletableEntity.expired.each do |deletable_entity|
        Commands::Delete.new(
          business_reference: deletable_entity.business_reference,
          reason: Types::DeletionReason['retention_rule'],
          deleted_by: 'system_automated'
        ).call
      end

      Rails.logger.info('End of automated deletion task')
    end
  end
end
