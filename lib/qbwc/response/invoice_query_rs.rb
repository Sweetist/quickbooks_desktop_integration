module QBWC
  module Response
    class InvoiceQueryRs
      attr_reader :records

      def initialize(records)
        @records = records
      end

      def handle_error(errors, config)
        errors.each do |error|
          Persistence::Object.handle_error(config,
                                           error.merge({context: 'Querying Shipments'}),
                                           "shipments",
                                           error[:request_id])
        end
      end

      def process(config = {})
        return if records.empty?

        puts records.inspect

        config  = { origin: 'wombat', connection_id: config[:connection_id]  }.with_indifferent_access

        Persistence::Object.new(config, {}).update_objects_with_query_results(objects_to_update(config))

        nil
      end

      def objects_to_update(config)
        records.map do |record|
          {
            object_type: 'shipment',
            object_ref: record['RefNumber'],
            id: record['RefNumber'],
            list_id: record['TxnID'],
            edit_sequence: record['EditSequence'],
            extra_data: build_extra_data(config, record)
          }.with_indifferent_access
        end
      end

      def build_extra_data(config, record)
        hash_items = build_hash_items(record)
        object_source = Persistence::Object.new(config, {}).load_session(record['request_id'])

        mapped_lines = object_source['items'].to_a.map do |item|
          item['txn_line_id'] = hash_items[item['product_id'].downcase]
          item['txn_id']      = record['TxnID']
          item
        end

        mapped_adjustments = object_source['adjustments'].to_a.map do |item|
          item['txn_line_id'] = hash_items[item['name'].downcase]
          item['txn_id']      = record['TxnID']
          item
        end

        {
          'items' => mapped_lines,
          'adjustments' => mapped_adjustments
        }
      end

      def build_hash_items(record)
        hash = {}

        # Sometimes is an array, sometimes is not :-/
        record['SalesOrderLineRet'] = [record['SalesOrderLineRet']] unless record['SalesOrderLineRet'].is_a? Array

        record['SalesOrderLineRet'].to_a.each do |item|
          hash[item['ItemRef']['FullName'].downcase] = item['TxnLineID']
        end
        hash
      end

      def to_wombat
        # TODO finish the map
        records.map do |record|
          object = {
            id: record['RefNumber'],
          }

          object
        end
      end
    end
  end
end
