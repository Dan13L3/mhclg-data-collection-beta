require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is a number" do
      expect { CaseLog.create!(age1: "random") }.to raise_error(ActiveRecord::RecordInvalid)
      expect { CaseLog.create!(age3: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is under 120" do
      expect { CaseLog.create!(age1: 121) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { CaseLog.create!(age3: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is over 0" do
      expect { CaseLog.create!(age1: 0) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { CaseLog.create!(age3: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is a number" do
      expect { CaseLog.create!(offered: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is under 20" do
      expect { CaseLog.create!(offered: 21) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is over 0" do
      expect { CaseLog.create!(offered: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "reasonable preference is yes" do
      it "validates a reason must be selected" do
        expect {
          CaseLog.create!(reasonpref: "Yes",
                          rp_homeless: nil,
                          rp_insan_unsat: nil,
                          rp_medwel: nil,
                          rp_hardship: nil,
                          rp_dontknow: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validates that previously homeless should be selected" do
        expect {
          CaseLog.create!(
            homeless: "No",
            reasonpref: "Yes",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "reasonable preference is no" do
      it "validates no reason is needed" do
        expect {
          CaseLog.create!(reasonpref: "No", rp_homeless: "No")
        }.not_to raise_error
      end

      it "validates that no reason has been provided" do
        expect {
          CaseLog.create!(
            reasonpref: "No",
            rp_medwel: "Yes",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "reason for leaving last settled home validation" do
      it "Reason for leaving must be don't know if reason for leaving settled home (Q9a) is don't know." do
        expect {
          CaseLog.create!(reason: "Do not know",
                          underoccupation_benefitcap: "Yes - benefit cap")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "other reason for leaving last settled home validation" do
      it "must be provided if main reason for leaving last settled home was given as other" do
        expect {
          CaseLog.create!(reason: "Other",
                          other_reason_for_leaving_last_settled_home: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must not be provided if the main reason for leaving settled home is not other" do
        expect {
          CaseLog.create!(reason: "Repossession",
                          other_reason_for_leaving_last_settled_home: "the other reason provided")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "armed forces injured validation" do
      it "must be answered if tenant was a regular or reserve in armed forces" do
        expect {
          CaseLog.create!(armedforces: "A current or former regular in the UK Armed Forces (exc. National Service)",
                          reservist: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must be answered if tenant was not a regular or reserve in armed forces" do
        expect {
          CaseLog.create!(armedforces: "No",
                          reservist: "Yes")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "Validate pregnancy questions" do
      it "Cannot answer yes if no female tenants" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Male",
                          age1: 20)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot answer yes if no female tenants within age range" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Female",
                          age1: 51)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot answer prefer not to say if no valid tenants" do
        expect {
          CaseLog.create!(preg_occ: "Prefer not to say",
                          sex1: "Male",
                          age1: 20)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Can answer yes if valid tenants" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Female",
                          age1: 20)
        }.not_to raise_error
      end

      it "Can answer yes if valid second tenant" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Male", age1: 99,
                          sex2: "Female",
                          age2: 20)
        }.not_to raise_error
      end
    end

    context "Shared accomodation bedrooms validation" do
      it "you must have more than zero bedrooms" do
        expect {
          CaseLog.create!(unittype_gn: "Shared house",
                          beds: 0)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "you must answer less than 8 bedrooms" do
        expect {
          CaseLog.create!(unittype_gn: "Shared bungalow",
                          beds: 8,
                          other_hhmemb: 1)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "you must answer less than 8 bedrooms" do
        expect {
          CaseLog.create!(unittype_gn: "Shared bungalow",
                          beds: 4,
                          other_hhmemb: 0)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "A bedsit must only have one room" do
        expect {
          CaseLog.create!(unittype_gn: "Bed-sit",
                          beds: 2)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "A bedsit must only have one room" do
        expect {
          CaseLog.create!(unittype_gn: "Bed-sit",
                          beds: 0)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "outstanding rent or charges validation" do
      it "must be anwered if answered yes to outstanding rent or charges" do
        expect {
          CaseLog.create!(hbrentshortfall: "Yes",
                          tshortfall: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must be not be anwered if answered no to outstanding rent or charges" do
        expect {
          CaseLog.create!(hbrentshortfall: "No",
                          tshortfall: 99)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "tenant’s income is from Universal Credit, state pensions or benefits" do
      it "Cannot be All if person 1 works full time" do
        expect {
          CaseLog.create!(benefits: "All", ecstat1: "Full-time - 30 hours or more")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot be All if person 1 works part time" do
        expect {
          CaseLog.create!(benefits: "All", ecstat1: "Part-time - Less than 30 hours")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot be 1 All if any of persons 2-4 are person 1's partner and work part or full time" do
        expect {
          CaseLog.create!(benefits: "All", relat2: "Partner", ecstat2: "Part-time - Less than 30 hours")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "fixed term tenancy length" do
      it "Must not be completed if Type of main tenancy is not responded with either Secure or Assured shorthold " do
        expect {
          CaseLog.create!(tenancy: "Other",
                          tenancylength: 10)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Must be completed and between 2 and 99 if type of tenancy is Assured shorthold" do
        expect {
          CaseLog.create!(tenancy: "Assured Shorthold",
                          tenancylength: 1)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Assured Shorthold",
                          tenancylength: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Assured Shorthold",
                          tenancylength: 2)
        }.not_to raise_error
      end

      it "Must be empty or between 2 and 99 if type of tenancy is Secure" do
        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancylength: 1)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancylength: 100)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancylength: nil)
        }.not_to raise_error

        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancylength: 2)
        }.not_to raise_error
      end
    end

    context "armed forces active validation" do
      it "must be answered if ever served in the forces as a regular" do
        expect {
          CaseLog.create!(armedforces: "A current or former regular in the UK Armed Forces (exc. National Service)",
                          leftreg: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must not be answered if not ever served as a regular" do
        expect {
          CaseLog.create!(armedforces: "No",
                          leftreg: "Yes")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      # Crossover over tests here as injured must be answered as well for no error
      it "must be answered if ever served in the forces as a regular" do
        expect do
          CaseLog.create!(armedforces: "A current or former regular in the UK Armed Forces (exc. National Service)",
                          leftreg: "Yes",
                          reservist: "Yes")
        end
      end
    end

    context "household_member_validations" do
      it "validate that persons aged under 16 must have relationship Child" do
        expect { CaseLog.create!(age2: 14, relat2: "Partner") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that persons aged over 70 must be retired" do
        expect { CaseLog.create!(age2: 71, ecstat2: "Full-time - 30 hours or more") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that a male, retired persons must be over 65" do
        expect { CaseLog.create!(age2: 64, sex2: "Male", ecstat2: "Retired") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that a female, retired persons must be over 60" do
        expect { CaseLog.create!(age2: 59, sex2: "Female", ecstat2: "Retired") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that persons aged under 16 must be a child (economically speaking)" do
        expect { CaseLog.create!(age2: 15, ecstat2: "Full-time - 30 hours or more") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that persons aged between 16 and 19 that are a child must be a full time student or economic status refused" do
        expect { CaseLog.create!(age2: 17, relat2: "Child - includes young adult and grown-up", ecstat2: "Full-time - 30 hours or more") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that persons aged under 16 must be a child relationship" do
        expect { CaseLog.create!(age2: 15, relat2: "Partner") }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validate that no more than 1 partner relationship exists" do
        expect { CaseLog.create!(relat2: "Partner", relat3: "Partner") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "other tenancy type validation" do
      it "must be provided if tenancy type was given as other" do
        expect {
          CaseLog.create!(tenancy: "Other",
                          tenancyother: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Other",
                          tenancyother: "type")
        }.not_to raise_error
      end

      it "must not be provided if tenancy type is not other" do
        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancyother: "the other reason provided")
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy: "Secure (including flexible)",
                          tenancyother: nil)
        }.not_to raise_error
      end
    end

    context "income ranges" do
      it "validates net income maximum" do
        expect {
          CaseLog.create!(
            ecstat1: "Full-time - 30 hours or more",
            earnings: 5000,
            incfreq: "Weekly",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validates net income minimum" do
        expect {
          CaseLog.create!(
            ecstat1: "Full-time - 30 hours or more",
            earnings: 1,
            incfreq: "Weekly",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "given an income in upper soft validation range" do
        let(:case_log) do
          FactoryBot.create(:case_log,
                            ecstat1: "Full-time - 30 hours or more",
                            earnings: 750,
                            incfreq: "Weekly")
        end

        it "updates soft errors" do
          expect(case_log.has_no_unresolved_soft_errors?).to be false
          expect(case_log.soft_errors["override_net_income_validation"].message)
            .to match(/Net income is higher than expected/)
        end
      end

      context "given an income in lower soft validation range" do
        let(:case_log) do
          FactoryBot.create(:case_log,
                            ecstat1: "Full-time - 30 hours or more",
                            earnings: 120,
                            incfreq: "Weekly")
        end

        it "updates soft errors" do
          expect(case_log.has_no_unresolved_soft_errors?).to be false
          expect(case_log.soft_errors["override_net_income_validation"].message)
            .to match(/Net income is lower than expected/)
        end
      end
    end

    context "major repairs date" do
      it "cannot be later than the tenancy start date" do
        expect {
          CaseLog.create!(
            mrcdate: Date.new(2020, 10, 10),
            startdate: Date.new(2020, 10, 9),
          )
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(
            mrcdate: Date.new(2020, 10, 9),
            startdate: Date.new(2020, 10, 10),
          )
        }.not_to raise_error
      end

      it "must not be completed if reason for vacancy is first let" do
        expect {
          CaseLog.create!(
            mrcdate: Date.new(2020, 10, 10),
            rsnvac: "First let of newbuild property",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(
            mrcdate: Date.new(2020, 10, 10),
            rsnvac: "First let of conversion/rehabilitation/acquired property",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(
            mrcdate: Date.new(2020, 10, 10),
            rsnvac: "First let of leased property",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must have less than two years between the tenancy start date and major repairs date" do
        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            mrcdate: Date.new(2017, 10, 10),
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "void date" do
      it "must have less than 10 years between the tenancy start date and void" do
        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            property_void_date: Date.new(2009, 10, 10),
          )
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            property_void_date: Date.new(2015, 10, 10),
          )
        }.not_to raise_error
      end

      it "must be before the tenancy start date" do
        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            property_void_date: Date.new(2021, 10, 10),
          )
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            property_void_date: Date.new(2019, 10, 10),
          )
        }.not_to raise_error
      end

      it "must be before major repairs date if major repairs date provided" do
        expect {
          CaseLog.create!(
            startdate: Date.new(2020, 10, 10),
            mrcdate: Date.new(2019, 10, 10),
            property_void_date: Date.new(2019, 11, 11),
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "Validate pregnancy questions" do
      it "Cannot answer yes if no female tenants" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Male",
                          age1: 20)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot answer yes if no female tenants within age range" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Female",
                          age1: 51)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot answer prefer not to say if no valid tenants" do
        expect {
          CaseLog.create!(preg_occ: "Prefer not to say",
                          sex1: "Male",
                          age1: 20)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Can answer yes if valid tenants" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Female",
                          age1: 20)
        }.not_to raise_error
      end

      it "Can answer yes if valid second tenant" do
        expect {
          CaseLog.create!(preg_occ: "Yes",
                          sex1: "Male", age1: 99,
                          sex2: "Female",
                          age2: 20)
        }.not_to raise_error
      end
    end
  end

  describe "status" do
    let!(:empty_case_log) { FactoryBot.create(:case_log) }
    let!(:in_progress_case_log) { FactoryBot.create(:case_log, :in_progress) }
    let!(:completed_case_log) { FactoryBot.create(:case_log, :completed) }

    it "is set to not started for an empty case log" do
      expect(empty_case_log.not_started?).to be(true)
      expect(empty_case_log.in_progress?).to be(false)
      expect(empty_case_log.completed?).to be(false)
    end

    it "is set to in progress for a started case log" do
      expect(in_progress_case_log.in_progress?).to be(true)
      expect(in_progress_case_log.not_started?).to be(false)
      expect(in_progress_case_log.completed?).to be(false)
    end

    it "is set to completed for a completed case log" do
      expect(completed_case_log.in_progress?).to be(false)
      expect(completed_case_log.not_started?).to be(false)
      expect(completed_case_log.completed?).to be(true)
    end
  end

  describe "incref" do
    let(:case_log) { FactoryBot.build(:case_log, net_income_known: "Prefer not to say") }

    it "sets income refused to Yes" do
      expect(case_log.incref).to eq(1)
    end
  end

  describe "weekly_net_income" do
    let(:net_income) { 5000 }
    let(:case_log) { FactoryBot.build(:case_log, earnings: net_income) }

    it "returns input income if frequency is already weekly" do
      case_log.incfreq = "Weekly"
      expect(case_log.weekly_net_income).to eq(net_income)
    end

    it "calculates the correct weekly income from monthly income" do
      case_log.incfreq = "Monthly"
      expect(case_log.weekly_net_income).to eq(1154)
    end

    it "calculates the correct weekly income from yearly income" do
      case_log.incfreq = "Yearly"
      expect(case_log.weekly_net_income).to eq(417)
    end
  end
end
