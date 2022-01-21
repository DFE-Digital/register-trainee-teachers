# frozen_string_literal: true

def enable_features(*feature_keys)
  stub_configured_features
  feature_keys.each do |feature_key|
    allow(FeatureService).to receive(:enabled?).with(feature_key).and_return(true)
  end
end

def disable_features(*feature_keys)
  stub_configured_features
  feature_keys.each do |feature_key|
    allow(FeatureService).to receive(:enabled?).with(feature_key).and_return(false)
  end
end

def stub_configured_features
  flatten(Settings.features.to_h).each do |k, v|
    allow(FeatureService).to receive(:enabled?).with(k).and_return(v)
    allow(FeatureService).to receive(:enabled?).with(k.to_sym).and_return(v)
  end
end

def flatten(hash_to_flatten)
  hash_to_flatten.reduce({}) do |result, (k, v)|
    flattened = v.is_a?(Hash) ? flatten(v).transform_keys { |k2| "#{k}.#{k2}" } : { k.to_s => v }
    result.merge(flattened)
  end
end
