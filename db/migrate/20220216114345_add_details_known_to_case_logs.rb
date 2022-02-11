class AddDetailsKnownToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :details_known_2, :string
    add_column :case_logs, :details_known_3, :string
    add_column :case_logs, :details_known_4, :string
    add_column :case_logs, :details_known_5, :string
    add_column :case_logs, :details_known_6, :string
    add_column :case_logs, :details_known_7, :string
    add_column :case_logs, :details_known_8, :string
  end
end
