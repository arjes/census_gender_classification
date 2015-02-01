require 'rails_helper'

RSpec.describe PersonPresenter do

  describe ".classifier" do
    it "memoizes the output of build_classifier" do
      expect(PersonPresenter).to receive(:build_classifier).once.and_return 1
      
      PersonPresenter.classifier
      PersonPresenter.classifier
    end
  end 

  describe ".valid_people_for_training" do
    let!(:person1) { Person.create(gender: 'male', height: 1, weight: 1) }
    let!(:person2) { Person.create(gender: '', height: 1, weight: 1 )}

    it "returns people with gender set" do
      expect(PersonPresenter.valid_people_for_training).to eq [person1]
    end
  end

  describe ".training_sets" do 
    let!(:person1) { Person.create(gender: 'male', height: 1, weight: 2) }
    let!(:person2) { Person.create(gender: 'female', height: 2, weight: 3) }

    it "groups people by their gender" do
      expect(PersonPresenter.training_sets).to eq(
        {
          female: [ {height: 2, weight: 3} ],
          male:   [ {height: 1, weight: 2} ]
        }
       )
    end
  end

  describe ".attributes_to_classify" do
    it "returns symbolized keys of the attributes" do
      expect(PersonPresenter.attributes_to_classify(Person.new(height: 1, weight: 2))).to eq(
        {height: 1, weight: 2}
      )
    end
  end

  describe ".build_classifier" do
    let(:faux_classifier) { double() }
      
    let!(:person1) { Person.create(gender: 'male', height: 1, weight: 2) }
    let!(:person2) { Person.create(gender: 'female', height: 2, weight: 3) }

    before do
      allow(NaiveBayesClassifier::Gaussian).to receive(:new).and_return(faux_classifier)
    end

    it "returns the classifier" do
      allow(faux_classifier).to receive(:train!)
      
      expect(PersonPresenter.build_classifier).to eq faux_classifier
    end

    it "trains on each training_set" do
      expect(faux_classifier).to receive(:train!).with(:male, [ { height: 1, weight: 2} ])
      expect(faux_classifier).to receive(:train!).with(:female, [ { height: 2, weight: 3} ])

      PersonPresenter.build_classifier
    end
  end

  describe "#gender" do
    it "returns the set value if non-blank" do
      presenter = PersonPresenter.new(Person.new(gender: 'foo'), nil)

      expect(presenter.gender).to eq 'foo'
    end

  end
end
