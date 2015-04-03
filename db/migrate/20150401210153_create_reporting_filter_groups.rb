class CreateReportingFilterGroups < ActiveRecord::Migration
  def change
    create_table :reporting_filter_groups do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
