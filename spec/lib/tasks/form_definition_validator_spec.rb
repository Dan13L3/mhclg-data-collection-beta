require "rails_helper"
require "rake"

RSpec.describe "form_definition" do
  describe ":validate_all", type: :task do
    subject(:task) { Rake::Task["form_definition:validate_all"] }

    before do
      Rake.application.rake_require("tasks/form_definition")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    it "runs the validate task for each form definition in the project" do
      expect(Rake::Task["form_definition:validate"]).to receive(:invoke).exactly(4).times
      task.invoke
    end
  end

  describe ":validate", type: :task do
    subject(:task) { Rake::Task["form_definition:validate"] }

    before do
      Rake.application.rake_require("tasks/form_definition")
      Rake::Task.define_task(:environment)
      allow(JSON::Validator).to receive(:validate).and_return(true)
      task.reenable
    end

    it "runs the validate task for the given form definition" do
      expect(JSON::Validator).to receive(:validate!).at_least(1).time
      task.invoke("config/forms/2021_2022.json")
    end
  end
end
