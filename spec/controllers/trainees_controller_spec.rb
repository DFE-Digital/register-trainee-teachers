require "rails_helper"

RSpec.describe TraineesController do
  describe "#show" do
    it "returns 200" do
      get :show, params: { id: 1 }
      expect(response).to be_successful
    end
  end

  describe "#new" do
    it "returns 200" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "#create" do
    let(:trainee_attributes) { attributes_for(:trainee_for_form) }
    let(:latest_trainee) { Trainee.last }

    before do
      post :create, params: { trainee: trainee_attributes }
    end

    it "creates record with correct data" do
      trainee_attributes.reject { |k, _| k.to_s.include?("date_of_birth") }.each do |k, _v|
        expect(latest_trainee.public_send(k)).to eql(trainee_attributes[k])
      end

      expect(latest_trainee.date_of_birth).to eql(
        Date.new(trainee_attributes[:"date_of_birth(1i)"].to_i,
                 trainee_attributes[:"date_of_birth(2i)"].to_i,
                 trainee_attributes[:"date_of_birth(3i)"].to_i),
      )
    end

    it "create record and redirects to show page" do
      expect(response).to redirect_to(trainee_path(latest_trainee))
    end
  end
end
