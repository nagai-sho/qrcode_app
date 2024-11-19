class CreateQrcodes < ActiveRecord::Migration[7.0]
  def change
    create_table :qrcodes do |t|

      t.timestamps
    end
  end
end
