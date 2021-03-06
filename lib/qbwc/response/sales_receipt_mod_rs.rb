module QBWC
  module Response
    class SalesReceiptModRs
      attr_reader :records

      def initialize(records)
        @records = records
      end

      def handle_error(errors, config)
        errors.each do |error|
          Persistence::Object.handle_error(config,
                                           error.merge(context: 'Adding returns'),
                                           'returns',
                                           error[:request_id])
        end
      end

      def process(config = {})
        orders = records.inject([]) do |orders, record|
          orders << {
            returns: {
              id: record['RefNumber'],
              list_id: record['TxnID'],
              edit_sequence: record['EditSequence']
            }
          }
        end

        Persistence::Object.update_statuses(config, orders)
      end
    end
  end
end
