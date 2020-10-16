class TraineeProgressSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    hash = hash.is_a?(String) ? JSON.parse(hash) : hash
    (hash || {}).with_indifferent_access
  end
end
