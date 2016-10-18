module Quizer
  class QuizAttemptsController < ApplicationController
    include ResourcesHelper

    before_action :private_access
    before_action :set_subject
    before_action :set_quiz
    before_action :set_quiz_attempt, only: [:show,:finish,:results]

    def show
    end

    def create
      if @quiz.is_being_attempted_by_user?(current_user)
        redirect_to ongoing_quiz_attempt_for_user_path(@quiz,current_user)
      elsif @quiz_attempt = @quiz.quiz_attempts.create(user: current_user)
        redirect_to subject_resource_quiz_attempt_path(@subject, @quiz, @quiz_attempt.reload)
      else
        flash[:error] = "Algo salió mal"
        redirect_to :back
      end
    end

    def finish
      @quiz_attempt.finished!
      redirect_to results_subject_resource_quiz_attempt_path(@quiz_attempt.quiz.subject, @quiz_attempt.quiz, @quiz_attempt)
    end

    def results
      if @quiz.is_being_attempted_by_user?(current_user)
        redirect_to ongoing_quiz_attempt_for_user_path(@quiz,current_user)
      end
    end

    private
      def set_subject
        @subject = Subject.friendly.find(params[:subject_id])
      end

      def set_quiz
        @quiz = Quiz.friendly.find(params[:resource_id])
      end

      def set_quiz_attempt
        @quiz_attempt = QuizAttempt.find(params[:id])
      end
  end
end
