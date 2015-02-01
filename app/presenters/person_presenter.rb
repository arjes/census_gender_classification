class PersonPresenter < BasePresenter
  presents :person

  delegate :height, :weight, to: :person

  def self.classifier
    @classifier ||= build_classifier
  end

  def self.valid_people_for_training
    Person.where.not(gender: '')
  end

  def self.build_classifier
    classifier = NaiveBayesClassifier::Gaussian.new

    training_sets.each do |klass, training_set|
      classifier.train! klass, training_set 
    end
    
    classifier  
  end

  def self.training_sets
    valid_people_for_training.each_with_object({}) do |p, hsh|
      (hsh[p.gender.to_sym] ||= []) << attributes_to_classify(p)
    end
  end

  def self.attributes_to_classify person
    person.attributes.symbolize_keys.slice(:height, :weight)
  end

  def gender
    if person.gender.blank?
      h.content_tag :div, 
        self.class.classifier.classify(self.class.attributes_to_classify(person)),
        class: 'estimate'
    else
      person.gender
    end
  end
end
