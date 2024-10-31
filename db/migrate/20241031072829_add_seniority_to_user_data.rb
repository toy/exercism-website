class AddSeniorityToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :user_data, :seniority, :tinyint, null: true
  end
end
