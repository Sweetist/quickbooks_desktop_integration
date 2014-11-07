module QBWC
  module Response
    class ItemInventoryQueryRs
      attr_reader :records

      def initialize(records)
        @records = records
      end

      def process
        return if records.empty?

        puts records.inspect
        puts to_wombat

        # config  = { origin: 'quickbooks', account_id: 'x123' }
        # payload = { products: to_wombat }

        # integration = Persistence::Object.new config, payload
        # s3_object = integration.save_to_s3

        # logger.info "File #{s3_object.key} persisted on s3"
      end

      private

      def to_wombat
        records.map do |record|
          object = {
            id: record['Name'],
            sku: record['Name'],
            product_id: record['Name'],
            quantity: record['QuantityOnHand']
          }

          # The price can be in many places :/
          if sales = record['SalesAndPurchase']
            object[:price]      = sales['SalesPrice']
            object[:cost_price] = sales['PurchaseCost']
          elsif sales = record['SalesOrPurchase']
            object[:price]      = sales['Price']
            object[:cost_price] = sales['Cost']
          else
            object[:price]      = record['SalesPrice']
            object[:cost_price] = record['PurchaseCost']
          end

          object
        end
      end
    end
  end
end
