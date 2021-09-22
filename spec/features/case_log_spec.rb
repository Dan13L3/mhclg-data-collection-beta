require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }
  pages = %w[tenant_code tenant_age tenant_gender tenant_ethnic_group tenant_nationality tenant_economic_status household_number_of_other_members]

  describe "Create new log" do
    it "redirects to the task list for the new log" do
      visit("/case_logs")
      click_link("Create new log")
      id = CaseLog.order(created_at: :desc).first.id
      expect(page).to have_content("Tasklist for log #{id}")
    end
  end

  describe "Viewing a log" do
    it "displays a tasklist header" do
      visit("/case_logs/#{id}")
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
      visit page.driver.request.env["HTTP_REFERER"]
      expect(page).to have_field("tenant-age-field")
    end

    describe "form questions" do
      it "can be accessed by url" do
        visit("/case_logs/#{id}/tenant_age")
        expect(page).to have_field("tenant-age-field")
      end

      it "updates model attributes correctly for each question" do
        visit("/case_logs/#{id}/tenant_code")
        fill_in(:tenant_code, with: "BZ737")
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_code
        }.from("TH356").to("BZ737")

        visit("/case_logs/#{id}/tenant_age")
        fill_in(:tenant_age, with: 25)
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_age
        }.from(NilClass).to(25)

        visit("/case_logs/#{id}/tenant_gender")
        choose("tenant-gender-1-field")
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_gender
        }.from(NilClass).to("1")

        visit("/case_logs/#{id}/tenant_ethnic_group")
        choose("tenant-ethnic-group-2-field")
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_ethnic_group
        }.from(NilClass).to("2")

        visit("/case_logs/#{id}/tenant_nationality")
        choose("tenant-nationality-0-field")
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_nationality
        }.from(NilClass).to("0")

        visit("/case_logs/#{id}/tenant_economic_status")
        choose("tenant-economic-status-4-field")
        expect { click_button("Save and continue") }.to change {
          case_log.reload.tenant_economic_status
        }.from(NilClass).to("4")

        visit("/case_logs/#{id}/household_number_of_other_members")
        fill_in(:household_number_of_other_members, with: 2)
        expect { click_button("Save and continue") }.to change {
          case_log.reload.household_number_of_other_members
        }.from(NilClass).to(2)
      end
    end

    describe "Back link directs correctly" do
      it "go back to tasklist page from tenant code" do
        visit("/case_logs/#{id}/tenant_code")
        click_link(text: "Back")
        expect(page).to have_content("Tasklist for log #{id}")
      end

      it "go back to tenant code page from tenant age page" do
        visit("/case_logs/#{id}/tenant_age")
        click_link(text: "Back")
        expect(page).to have_field("tenant-code-field")
      end
    end
  end

  describe "Form flow is correct" do
    context "given an ordered list of pages" do
      it "leads to the next one in the correct order" do
        pages[0..-2].each_with_index do |val, index|
          visit("/case_logs/#{id}/#{val}")
          click_button("Save and continue")
          expect(page).to have_current_path("/case_logs/#{id}/#{pages[index + 1]}")
        end
      end
    end
  end
end
