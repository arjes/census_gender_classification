require 'rails_helper'

RSpec.describe Person, :type => :model do
  
  describe "#valid?" do
    let(:valid_attributes) { {gender: 'male', height: 5, weight: 5} }

    it "is valid given the default valid attributes" do
      expect(Person.new(valid_attributes)).to be_valid
    end

    context '.gender' do
      it "is valid if the gender is set to female" do
        expect(Person.new(valid_attributes.merge(gender: 'female')) ).to be_valid
      end
  
      it "is valid if the gender is set to male" do
        expect(Person.new(valid_attributes.merge(gender: 'male')) ).to be_valid
      end
  
      it "is valid if the gender is blak" do
        expect(Person.new(valid_attributes.merge(gender: '')) ).to be_valid
      end
  
      it "is invalid if the gender is set to a value other than (fe)male or blank" do
        expect(Person.new(valid_attributes.merge(gender: 'sadflkjsdf')) ).to_not be_valid
      end
    end

    context "weight" do
      it "requires a weight be set" do
        expect(Person.new(valid_attributes.merge(weight: '') )).to_not be_valid
      end
    end

    context "height" do
      it "requires a height be set" do
        expect(Person.new(valid_attributes.merge(height: '') )).to_not be_valid
      end
    end
  end
end
