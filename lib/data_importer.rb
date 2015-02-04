require 'json'

class DataImporter
  attr_accessor :file_name

  def initialize file_name
    self.file_name = file_name
  end

  def import!
    valid_entries.in_groups_of(10) do |entries|
      run_insert_query entries.compact
    end
  end

  def run_insert_query entries
    ActiveRecord::Base.connection.execute "
        INSERT INTO 
          #{Person.quoted_table_name} (`gender`,`height`,`weight`,`created_at`,`updated_at`)
        VALUES
          #{entries.collect{|e| insert_entry(e)}.join(',')}
      "
  end

  def insert_entry hsh
    "(#{escape(hsh['gender'])},#{escape(hsh['height'])},#{escape(hsh['weight'])},#{escape(Time.now.to_s(:db))},#{escape(Time.now.to_s(:db))})"
  end

  def escape entry
    ActiveRecord::Base.connection.quote entry
  end

  def normalize_entry hsh
    hsh['gender'] = hsh['gender'].downcase
    hsh['height'] = hsh['height'].to_f
    hsh['weight'] = hsh['weight'].to_f
    hsh
  end

  def valid_entries 
    raw_entries.collect do |entry|
      normalize_entry(entry) if valid_entry?(entry)
    end.compact
  end

  def valid_entry? hsh
    hsh.has_key?("height") and
      hsh.has_key?("weight") and
      hsh.has_key?("gender") and
      ['male','female'].include?(hsh["gender"].downcase)
  end

  def raw_entries
    data_from_file = data_hash_to_import

    return [] if !data_from_file['people'] or !data_from_file['people'].is_a?(Array)

    data_from_file['people'].collect do |i| 
      i['person'] if i.is_a? Hash
    end.compact
  end

  def data_hash_to_import
    if File.readable? self.file_name
      JSON.parse(File.read(self.file_name))
    else
      {}
    end
  rescue JSON::ParserError
    $stderr.puts "JSON parse error"
    {}
  end
end
