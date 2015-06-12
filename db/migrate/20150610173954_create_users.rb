class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :business_name
      t.string :admin_name
      t.string :admin_surname
      t.string :email
      t.string :password_hash
      t.string :subscription_type
      t.string :website_url

      t.timestamps
    end
  end
end
