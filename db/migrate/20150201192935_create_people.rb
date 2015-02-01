class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :gender
      t.float :height
      t.float :weight

      t.timestamps null: false
    end
  end
end
