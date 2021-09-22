require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log) { FactoryBot.create(:case_log) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }
  pages = ['tenant_code', 'tenant_age', 'tenant_gender', 'tenant_ethnic_group', 'tenant_nationality', 'economic_status', 'other_household_members']

  describe "Create new log" do
    it "redirects to the task list for the new log" do
      visit("/case_logs")
      click_link("Create new log")
      id = CaseLog.first.id
      expect(page).to have_content("Tasklist for log #{id}")
    end
  end

  describe "Viewing a log" do
    it "displays a tasklist header" do
      visit("/case_logs/342351")
      expect(page).to have_content("Tasklist for log #{id}")
      expect(page).to have_content("This submission is #{status}")
    end

    it "displays the household questions when you click into that section" do
      visit("/case_logs/#{id}")
      click_link("Household characteristics")
      expect(page).to have_field("tenant-code-field")
      click_button("Save and continue")
      expect(page).to have_field("tenant-age-field")
      click_button("Save and continue")
      expect(page).to have_field("tenant-gender-0-field")
      visit page.driver.request.env['HTTP_REFERER']
      expect(page).to have_field("tenant-age-field")
    end

    describe "form questions" do
      it "can be accessed by url" do
        visit("/case_logs/#{id}/tenant_age")
        expect(page).to have_field("tenant-age-field")
      end
    end
  end

  describe "Back link directs correctly" do
    it "go back to tasklist page from tenant code" do
      visit("/case_logs/#{id}/tenant_code")
      click_link(text: 'Back')
      expect(page).to have_content("Tasklist for log #{id}")
    end

    it "go back to tenant code page from tenant age page" do
      visit("/case_logs/#{id}/tenant_age")
      click_link(text: 'Back')
      expect(page).to have_field("tenant-code-field")
    end
  end

  describe "Form flow is correct" do
    it "given an ordered list of pages make sure each leads to the next one in order" do
      pages[0..-2].each_with_index {
        |val, index|
        visit("/case_logs/#{id}/#{val}")
        click_button("Save and continue")
        expect(page).to have_current_path("/case_logs/#{id}/#{pages[index+1]}")
      }
    end
  end
end
