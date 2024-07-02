# frozen_string_literal: true

def enable_dfe_analytics
  enable_features("google.send_data_to_big_query")
  allow(DfE::Analytics).to receive(:enabled?).and_return(true)
end

def disable_dfe_analytics
  disable_features("google.send_data_to_big_query")
  allow(DfE::Analytics).to receive(:enabled?).and_return(false)
end
