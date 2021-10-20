class CaseLogValidator < ActiveModel::Validator
  # Methods to be used on save and continue need to be named 'validate_'
  # followed by field name this is how the metaprogramming of the method
  # name being call in the validate method works.

  def validate_tenant_age(record)
    if record.tenant_age && !/^[1-9][0-9]?$|^120$/.match?(record.tenant_age.to_s)
      record.errors.add :tenant_age, "must be between 0 and 120"
    end
  end

  def validate_property_number_of_times_relet(record)
    if record.property_number_of_times_relet && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.property_number_of_times_relet.to_s)
      record.errors.add :property_number_of_times_relet, "must be between 0 and 20"
    end
  end

  def validate_other_reason_for_leaving_last_settled_home(record)
    if record.reason_for_leaving_last_settled_home == "Other" && record.other_reason_for_leaving_last_settled_home.blank?
      record.errors.add :other_reason_for_leaving_last_settled_home, "If reason for leaving settled home is other then the other reason must be provided"
    end

    if record.reason_for_leaving_last_settled_home != "Other" && record.other_reason_for_leaving_last_settled_home.present?
      record.errors.add :other_reason_for_leaving_last_settled_home, "The other reason must not be provided if the reason for leaving settled home was not other"
    end
  end

  def validate(record)
    # If we've come from the form UI we only want to validate the specific fields
    # that have just been submitted. If we're submitting a log via API or Bulk Upload
    # we want to validate all data fields.
    question_to_validate = options[:previous_page]
    if question_to_validate && respond_to?("validate_#{question_to_validate}")
      public_send("validate_#{question_to_validate}", record)
    else
      # This assumes that all methods in this class other than this one are
      # validations to be run
      validation_methods = public_methods(false) - [__callee__]
      validation_methods.each { |meth| public_send(meth, record) }
    end
  end
end

class CaseLog < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }

  validate :instance_validations
  before_save :update_status!

  attr_writer :previous_page

  enum status: { "not_started" => 0, "in_progress" => 1, "completed" => 2 }

  AUTOGENERATED_FIELDS = %w[id status created_at updated_at discarded_at].freeze

  def instance_validations
    validates_with CaseLogValidator, ({ previous_page: @previous_page } || {})
  end

  def self.editable_fields
    attribute_names - AUTOGENERATED_FIELDS
  end

  def completed?
    status == "completed"
  end

  def not_started?
    status == "not_started"
  end

  def in_progress?
    status == "in_progress"
  end

private

  def update_status!
    self.status = if all_fields_completed? && errors.empty?
                    "completed"
                  elsif all_fields_nil?
                    "not_started"
                  else
                    "in_progress"
                  end
  end

  def all_fields_completed?
    mandatory_fields.none? { |_key, val| val.nil? }
  end

  def all_fields_nil?
    mandatory_fields.all? { |_key, val| val.nil? }
  end

  def mandatory_fields
    required = attributes.except(*AUTOGENERATED_FIELDS)

    dynamically_not_required = []

    if reason_for_leaving_last_settled_home != "Other"
      dynamically_not_required << "other_reason_for_leaving_last_settled_home"
    end

    if net_income.to_i == 0
     dynamically_not_required << "net_income_frequency" 
    end

    required.delete_if { |key, _value| dynamically_not_required.include?(key) }
  end
end
