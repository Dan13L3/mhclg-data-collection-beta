require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Navigation" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { case_log.id }
  let(:question_answers) do
    {
      tenant_code: { type: "text", answer: "BZ737", path: "tenant-code" },
      age1: { type: "numeric", answer: 25, path: "person-1-age" },
      sex1: { type: "radio", answer: "Female", path: "person-1-gender" },
      other_hhmemb: { type: "numeric", answer: 6, path: "household-number-of-other-members" },
    }
  end

  before do
    sign_in user
  end

  describe "Create new log" do
    it "redirects to the task list for the new log" do
      visit("/logs")
      click_button("Create new log")
      id = CaseLog.order(created_at: :desc).first.id
      expect(page).to have_content("Log #{id}")
    end
  end

  describe "Viewing a log" do
    it "questions can be accessed by url" do
      visit("/logs/#{id}/person-1-age")
      expect(page).to have_field("case-log-age1-field")
    end

    it "a question page leads to the next question defined in the form definition" do
      pages = question_answers.map { |_key, val| val[:path] }
      pages[0..-2].each_with_index do |val, index|
        visit("/logs/#{id}/#{val}")
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{id}/#{pages[index + 1]}")
      end
    end


    describe "Multiple additional tenant question flow" do
      base_path = "/logs/#{id}/household-characteristics/other-tenants"
      ot_num = 1
      it "asks user if details are known for additional tenant number #{ot_num}" do
        visit("#{base_path}/#{ot_num}/details-known")
        expect(page.to have_selector("case-log-relat#{ot_num}-havedetails-yes-field"))
        expect(page.to have_selector("case-log-relat#{ot_num}-havedetails-no-field"))
      end

      it "should take the user to the next question for additional tenant #{ot_num} details when selecting YES" do
        visit("#{base_path}/details-known")
        choose("case-log-age#{ot_num}-known-yes-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("#{base_path}/#{ot_num}/relationship-to-lead")
      end

      it "should take the user to the next question for additional tenant #{ot_num} details when selecting NO" do
        visit("#{base_path}/other-member/#{ot_num}/details-known")
        choose("case-log-age#{ot_num}-known-no-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{id}/household-characteristics/check-answers")
      end
    end
    describe "Back link directs correctly", js: true do
      it "go back to tasklist page from tenant code" do
        visit("/logs/#{id}")
        visit("/logs/#{id}/tenant-code")
        click_link(text: "Back")
        expect(page).to have_content("Log #{id}")
      end

      it "go back to tenant code page from tenant age page", js: true do
        visit("/logs/#{id}/tenant-code")
        click_button("Save and continue")
        visit("/logs/#{id}/person-1-age")
        click_link(text: "Back")
        expect(page).to have_field("case-log-tenant-code-field")
      end

      it "doesn't get stuck in infinite loops", js: true do
        visit("/logs")
        visit("/logs/#{id}/net-income")
        fill_in("case-log-earnings-field", with: 740)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        click_link(text: "Back")
        click_link(text: "Back")
        expect(page).to have_current_path("/logs")
      end

      context "when changing an answer from the check answers page", js: true do
        it "the back button routes correctly" do
          visit("/logs/#{id}/household-characteristics/check-answers")
          first("a", text: /Answer/).click
          click_link("Back")
          expect(page).to have_current_path("/logs/#{id}/household-characteristics/check-answers")
        end
      end
    end
  end
end
