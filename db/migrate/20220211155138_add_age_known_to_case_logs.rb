class AddAgeKnownToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :age1_known, :string
    add_column :case_logs, :age2_known, :string
    add_column :case_logs, :age3_known, :string
    add_column :case_logs, :age4_known, :string
    add_column :case_logs, :age5_known, :string
    add_column :case_logs, :age6_known, :string
    add_column :case_logs, :age7_known, :string
    add_column :case_logs, :age8_known, :string
  end
end
