class FeedbackQuestionsController < ApplicationController

  def index
    @feedback_questions = FeedbackQuestion.all
  end

  def new
    @feedback_question = FeedbackQuestion.new
  end

  def create
    @feedback_question = FeedbackQuestion.new(feedback_question_params)
    if @feedback_question.save
      flash[:success] = 'Question successfully added'
    else
      flash[:danger] = @feedback_question.errors.full_messages.join(",")
    end
    @feedback_questions = FeedbackQuestion.all
  end

  def edit
    @feedback_question = FeedbackQuestion.find(params[:id])
  end

  def update
    @feedback_question = FeedbackQuestion.find(params[:id])
    if @feedback_question.update(feedback_question_params)
      flash[:success] = 'Question successfully updates'
    else
      flash[:danger] = @feedback_question.errors.full_messages.join(",")
    end
    @feedback_questions = FeedbackQuestion.all
  end

  def destroy
    @feedback_question = FeedbackQuestion.find(params[:id])
    if @feedback_question.destroy
      flash[:successfully] = 'Question successsully deleted'
    else
      flash[:danger] = @feedback_question.errors.full_messages.join(",")
    end
    @feedback_questions = FeedbackQuestion.all
  end

  private
  def feedback_question_params
    params.require(:feedback_question).permit(:title)
  end
end
