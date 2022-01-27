class AddDurationToPromoCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_codes, :duration_in_months, :integer
  end
end
