# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  challenge_id :integer
#  status       :integer
#  attempts     :integer          default("0")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Solution < ActiveRecord::Base
  has_paper_trail on: [:update]

  belongs_to :user
  belongs_to :challenge
  has_many :documents, as: :folder

  enum status: [:created, :completed, :failed]

  after_create :create_documents

  def evaluate
    self.attempts += 1 # new attempt

    begin
      eval "module Evaluator#{id}; end"
      eval "Evaluator#{id}.instance_eval('#{challenge.evaluation}')" # this creates an evaluate method used below
      files = documents.each_with_object({}) { |document, f| f[document.name] = document }
      error = eval "Evaluator#{id}.evaluate(files)"

      self.status = error ? :failed : :completed

      save!
      return error
    rescue Exception => e
      puts e.message
      puts e.backtrace
      return "Hemos encontrado un error en el evaluador, favor reportar a info@makeitreal.camp: #{e.message}"
    end
  end

  private
    def create_documents
      challenge.documents.each do |document|
        documents.create(name: document.name, content: document.content)
      end
    end
end