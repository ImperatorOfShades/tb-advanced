class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_question
  before_action :set_answer, only: %i[show destroy update best]
  before_action :author?, only: %i[destroy update]

  def show; end

  def new
    @answer = @question.answers.new
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    @answer.save
  end

  def destroy
    @answer.destroy
    # redirect_to question_path(@question),
    #             notice: 'Your answer was successfully deleted.'
  end

  def update
    @answer.update(answer_params)
  end

  def best
    @answer.make_best
  end

  private

  def author?
    unless @answer.author? current_user
      redirect_to question_path(@question), notice: 'You are not author of this answer!'
    end
  end

  def answer_params
    params.require(:answer).permit(:body)
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_answer
    @answer = @question.answers.find(params[:id])
  end
end
