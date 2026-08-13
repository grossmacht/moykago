class AddReferralLoyaltyToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :referral_code, :string
    add_column :customers, :referred_by_id, :bigint
    add_column :customers, :bonus_balance, :integer, null: false, default: 0
    add_column :customers, :referral_bonus_granted, :boolean, null: false, default: false
    add_index :customers, :referral_code, unique: true
    add_index :customers, :referred_by_id
  end
end
