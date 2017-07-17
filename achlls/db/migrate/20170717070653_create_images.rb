class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :src
      t.text :alt

      t.timestamps
    end
  end
end
