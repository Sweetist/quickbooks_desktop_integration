require 'spec_helper'

module QBWC
  describe Consumer do
    it "process item inventory query poll request" do
      xml = Factory.item_inventory_query_rs_raw_qbxml
      subject = described_class.new connection_id: "54591b3a5869632afc090000"
      Persistence::Object.any_instance.stub current_time: "1415755144"

      VCR.use_cassette "consumer/324543543525" do
        subject.digest_response_into_actions xml
      end
    end
  end
end
