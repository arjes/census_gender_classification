require 'rails_helper'


describe DataImporter do
  let(:file_name) { 'foo' }
  let(:importer)  { DataImporter.new(file_name) }
  let(:valid_data) do
    {
      "people" =>  [
        {
          "person" =>  {
            "id" =>  1,
            "height" =>  5.18,
            "weight" =>  166.67,
            "gender" =>  "Female"
          }
        }
      ]
    }
  end

  describe "#import!" do
    it "passes valid entries in blocks of 10" do
      allow(importer).to receive(:valid_entries).and_return( (1..15).to_a )

      expect(importer).to receive(:run_insert_query).with( (1..10).to_a)
      expect(importer).to receive(:run_insert_query).with( (11..15).to_a)

      importer.import!
    end

    context "when an error is raised" do
      it "writes to the STDERR" do
        allow(importer).to receive(:valid_entries).and_raise("OMG!")

        expect{importer.import!}.to output.to_stderr
      end
    end
  end
  
  describe "#run_insert_query" do
    it "creates an insert for the entire array" do
      data = [
        {"gender" => "male", "height"=>2, "weight" => 3 },
        {"gender" => "female", "height"=>2, "weight" => 3 }
      ]

      expect{importer.run_insert_query(data) }.to change{Person.count}.from(0).to(2)
    end
  end

  describe "#insert_entry" do
    it "creates the value string for the insert" do
      t = Time.now
      allow(Time).to receive(:now).and_return t

      expect(
        importer.insert_entry("gender" => "male", "height"=>2, "weight" => 3)
      ).to eq "('male',2,3,'#{t.to_s(:db)}','#{t.to_s(:db)}')"
    end
  end

  describe "#valid_entries" do
    it "removes invalid entries" do
      allow(importer).to receive(:raw_entries).and_return [
        { 'invalid_entry' => 'foo'},
        { 'gender' => 'male', 'weight' => 1.2, 'height' => 3.4 }
      ]

      expect(importer.valid_entries).to eq([{ 'gender' => 'male', 'weight' => 1.2, 'height' => 3.4 }])
    end
  end

  describe "#esape" do
    it "escapes the entry" do
      expect(importer.escape("asd'fgh")).to_not eq "asd'fgh"
    end
  end

  describe "#normalize_entry" do
    let(:dirty_data) { {'gender'=>'FoO', 'height' => '1.2', 'weight' => '2.2' } }
    it "downcases the gender entry" do
      expect(importer.normalize_entry(dirty_data)).to include 'gender' => 'foo'
    end

    it "converts height to a float" do
      expect(importer.normalize_entry(dirty_data)).to include 'height' => 1.2
    end
    
    it "converts weight to a float" do
      expect(importer.normalize_entry(dirty_data)).to include 'weight' => 2.2
    end
  end

  describe "#valid_entry?" do
    it "invalidates the entry  if it lacks height" do
      expect(
        importer.valid_entry?({"weight" => 2, "gender" => "male"})
      ).to be false
    end

    it "invalidates the entry  if it lacks weight" do
      expect(
        importer.valid_entry?({"height" => 1, "gender" => "male"})
      ).to be false
    end

    it "invalidates the entry  if it lacks gender" do
      expect(
        importer.valid_entry?({"height" => 1, "weight" => 2})
      ).to be false
    end

    it "invalidates the entry  if gender is not male/female" do
      expect(
        importer.valid_entry?({"height" => 1, "weight" => 2, "gender" => "foo"})
      ).to be false
    end
    
    
    it "validates an entry with all keys" do
      expect(
        importer.valid_entry?({"height" => 1, "weight" => 2, "gender" => "male"})
      ).to be true
    end

    it "gender is compared case-insensitive" do
      expect(
        importer.valid_entry?({"height" => 1, "weight" => 2, "gender" => "FEmale"})
      ).to be true
    end
    
  end

  describe "#raw_entries" do
    it "returns an empty array if people is not set" do
      allow(importer).to receive(:data_hash_to_import).and_return({})
      
      expect(importer.raw_entries).to eq []
    end

    it "returns an empty array if people is not an array" do
      allow(importer).to receive(:data_hash_to_import).and_return({"people" => "dude"})
      
      expect(importer.raw_entries).to eq []
    end

    it "consumes non hash entries in the people array" do
      allow(importer).to receive(:data_hash_to_import).and_return({"people" => ["dude"]})
      
      expect(importer.raw_entries).to eq []
    end

    it "removes entries where the root is not present" do
      valid_data["people"] << {}
      allow(importer).to receive(:data_hash_to_import).and_return valid_data
      
      expect(importer.raw_entries).to eq [{
            "id" =>  1,
            "height" =>  5.18,
            "weight" =>  166.67,
            "gender" =>  "Female"
          }]
    end

    it "collects the data within the array without the root" do
      allow(importer).to receive(:data_hash_to_import).and_return valid_data

      expect(importer.raw_entries).to eq [{
            "id" =>  1,
            "height" =>  5.18,
            "weight" =>  166.67,
            "gender" =>  "Female"
          }]
    end
  end

  describe "#data_hash_to_import" do
    context "if the file contains valid JSON" do
      it "retuns the parsed version of that data" do
        allow(File).to receive(:readable?).and_return true
        allow(File).to receive(:read).and_return '{"a":"b"}'

        expect(importer.data_hash_to_import).to eq({'a' => 'b'})
      end
    end
    context "if the file contains malformed JSON" do
      before do
        allow(File).to receive(:readable?).and_return true
        allow(File).to receive(:read).with(file_name).and_return '{}omg invalid json'
      end

      it "outputs a message to STDERR" do
        expect{importer.data_hash_to_import}.to output(/JSON parse error/).to_stderr
      end
      it "returns an empty hash" do
        expect(importer.data_hash_to_import).to eq({})
      end
    end

    context "if the file dosn't exist" do 
      it "returns an empty hash" do
        allow(File).to receive(:readable?).and_return false

        expect(importer.data_hash_to_import).to eq({})
      end
    end
  end 
end
