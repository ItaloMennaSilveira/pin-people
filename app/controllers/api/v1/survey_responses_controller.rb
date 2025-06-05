module Api
  module V1
    class SurveyResponsesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_survey_response, only: %i[show update destroy]

      def index
        @survey_responses = SurveyResponse
                            .by_user_id(params[:user_id])
                            .by_response_date_range(params[:start_date], params[:end_date])
                            .page(params[:page])
                            .per(params[:per_page] || 20)

        render json: {
          survey_responses: @survey_responses,
          meta: {
            current_page: @survey_responses.current_page,
            total_pages: @survey_responses.total_pages,
            total_count: @survey_responses.total_count
          }
        }
      end

      def show
        render json: @survey_response
      end

      def create
        @survey_response = SurveyResponse.new(survey_response_params)

        if @survey_response.save
          render json: @survey_response, status: :created
        else
          render json: { errors: @survey_response.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if survey_response_params.key?(:user_id) && survey_response_params[:user_id].nil?
          return render json: { error: 'user_id cannot be null' }, status: :unprocessable_entity
        end

        if @survey_response.update(survey_response_params)
          render json: @survey_response
        else
          render json: { errors: @survey_response.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @survey_response.destroy
        head :no_content
      end

      private

      def set_survey_response
        @survey_response = SurveyResponse.find(params[:id])
      end

      def survey_response_params
        params.require(:survey_response).permit(
          :user_id, :response_date,
          :interest_in_position, :comments_interest,
          :contribution, :comments_contribution,
          :learning_and_development, :comments_learning,
          :feedback, :comments_feedback,
          :manager_interaction, :comments_manager_interaction,
          :career_clarity, :comments_career_clarity,
          :permanence_expectation, :comments_permanence,
          :enps, :comments_enps
        )
      end
    end
  end
end
