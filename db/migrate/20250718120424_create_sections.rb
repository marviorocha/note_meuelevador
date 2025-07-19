class CreateSections < ActiveRecord::Migration[8.0]
   def change
    create_table :sections do |t|
      t.string :name
      t.timestamps
    end
  end
end
