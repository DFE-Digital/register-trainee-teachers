require "rails_helper"

describe Nationalisation do
  describe "associations" do
    it { should belong_to(:trainee) }
    it { should belong_to(:nationality) }
  end
end
