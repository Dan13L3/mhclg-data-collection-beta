require "rails_helper"
RSpec.describe "User Features" do
    let!(:user) { FactoryBot.create(:user) }
    context "A user navigating to case logs" do
        it " is required to log in" do
          visit("/case_logs")
          expect(page).to have_current_path("/users/sign_in")
        end

        it " is redirected to case logs after signing in" do
          visit("/case_logs")
          fill_in("user_email", with: "test@example.com")
          fill_in("user_password", with: "pAssword1")
          click_button("Log in")
          expect(page).to have_current_path("/case_logs")
        end 
    end
end