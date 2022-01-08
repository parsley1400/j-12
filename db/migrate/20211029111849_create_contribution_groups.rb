class CreateContributionGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :contribution_groups do |t|
      t.integer :contribution_id
      t.integer :group_id
  end
  end
end
