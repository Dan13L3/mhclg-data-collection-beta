module CheckAnswersHelper
  def get_answered_questions_total(subsection_pages, case_log)
    questions = []
    subsection_pages.keys.each do |page|
      questions << page
    end
    return questions.count {|question| !(case_log[question].blank?)}
  end


  def create_update_answer_link(case_log_answer, case_log_id, page)
    link_name = case_log_answer.blank? ? "Answer" : "Change"
    link_to(link_name, "/case_logs/#{case_log_id}/#{page}", class: "govuk-link").html_safe
  end

  def create_next_missing_question_link(case_log_id, subsections, case_log)
    empty_question = subsections.keys.find{|x| case_log[x].blank? }

    url = "/case_logs/#{case_log_id}/#{empty_question}"
    link_to('Answer the missing questions', url, class: "govuk-link").html_safe
  end

end
