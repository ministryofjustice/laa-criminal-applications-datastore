module Deleting
  module Commands
    class SyncMAATRecord
      def initialize(business_reference:)
        @business_reference = business_reference
      end

      def call
        repository.with_deletable(@business_reference) do |deletable|
          next unless deletable.maat_check_required?

          maat_client = MAAT::GetRecord.new

          # Applications that predate funding decisions won't have any decision_ids
          # They may have a maat_id provided by the Deleting::ApplicationMigrated event
          # Otherwise we need to fetch the record by USN
          if deletable.decision_ids.present?
            sync_by_decision_ids(deletable, maat_client)
          elsif deletable.maat_ids.present?
            deletable.maat_ids.each { |id| sync_by_maat_id(deletable, maat_client, id) }
          else
            sync_by_usn(deletable, maat_client)
          end
        end
      end

      private

      def sync_by_maat_id(deletable, maat_client, maat_id)
        maat_record = maat_client.by_maat_id!(maat_id)
        process(deletable, decision_id: maat_id, maat_record: maat_record)
      rescue MAAT::RecordNotFound => e
        Rails.error.report(e)
      end

      def sync_by_decision_ids(deletable, maat_client)
        deletable.decision_ids.each do |decision_id|
          decision = Decision.find_by(id: decision_id)
          maat_id = resolve_maat_id(decision, decision_id)
          next unless maat_id

          maat_record = maat_client.by_maat_id!(maat_id)
          process(deletable, decision_id:, maat_record:)
        rescue MAAT::RecordNotFound => e
          Rails.error.report(e)
        end
      end

      def resolve_maat_id(decision, decision_id)
        unless decision
          Rails.logger.warn("SyncMAATRecord: Decision not found for id #{decision_id} " \
                            "(reference: #{@business_reference})")
          return nil
        end

        unless decision.maat_id
          Rails.logger.info("SyncMAATRecord: Decision #{decision_id} has no maat_id, skipping " \
                            "(reference: #{@business_reference})")
          return nil
        end

        decision.maat_id
      end

      def sync_by_usn(deletable, maat_client)
        maat_record = maat_client.by_usn!(@business_reference)
        process(deletable, decision_id: maat_record.maat_ref, maat_record: maat_record)
      rescue MAAT::RecordNotFound => e
        Rails.error.report(e)
      end

      def process(deletable, decision_id:, maat_record:)
        updated_at = latest_maat_timestamp(maat_record, deletable.last_significant_event_at)
        return unless updated_at

        translated = MAAT::Translators::RecordTranslator.translate(maat_record)
        overall_decision = Deciding::OverallResultCalculator.new(translated).calculate

        deletable.update_maat_record(decision_id:, maat_record:, overall_decision:, updated_at:)
      end

      def latest_maat_timestamp(maat_record, last_significant_event_at)
        [maat_record.ioj_appeal_date, maat_record.date_means_created]
          .compact
          .select { |timestamp| timestamp > last_significant_event_at }
          .max
      end

      def repository
        @repository ||= Deleting::DeletableRepository.new
      end
    end
  end
end
