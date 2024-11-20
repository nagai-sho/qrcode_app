class AddColumnsToQrcodes < ActiveRecord::Migration[7.0]
  def change
    add_column :qrcodes, :url, :string
    add_column :qrcodes, :token, :string
    add_column :qrcodes, :expires_at, :datetime
    add_column :qrcodes, :file_name, :string
  end
end
