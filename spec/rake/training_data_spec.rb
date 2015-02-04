require 'rails_helper'

require 'support/shared_contexts/rake'

describe "training_data:load" do
  include_context "rake"

  it "requires the rails env" do
    expect(task.prerequisites).to include "environment"
  end

  it "accecpts 1 argument" do
    expect(task.arg_names.length).to eq 1
  end

  context "if the passed file can't be read" do
    it "outputs an message" do
      allow(File).to receive(:readable?).with('foo').and_return false

      expect { task.invoke 'foo'}.to output(/^Cannot Open File/).to_stdout
    end
  end

  context "if the file exists" do
    let(:faux_importer) { instance_double("DataImporter", :import! => true) }

    before do
      allow(File).to receive(:readable?).with('foo').and_return true
    end
    
    it "creates a DataImporter" do
      expect(DataImporter).to receive(:new).with('foo').and_return faux_importer

      task.invoke 'foo'
    end

    it "calls invoke on the created importer" do
      expect(faux_importer).to receive(:import!)
      allow(DataImporter).to receive(:new).and_return(faux_importer)

      task.invoke 'foo'
    end
  end 
end
