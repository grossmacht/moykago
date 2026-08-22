class AddPricingUnitToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :pricing_unit, :string, default: "fixed", null: false
  end
end
