module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        users = User.all
                    .by_department(params[:department_id])
                    .by_function(params[:function])
                    .by_position(params[:position])
                    .by_company_tenure(params[:company_tenure])
                    .by_genre(params[:genre])
                    .by_generation(params[:generation])
                    .page(params[:page])
                    .per(params[:per_page] || 20)

        render json: {
          current_page: users.current_page,
          total_pages: users.total_pages,
          total_count: users.total_count,
          users: users.as_json(only: %i[
                                 id name email company_email function position
                                 company_tenure genre generation department_id
                               ])
        }, status: :ok
      end

      def show
        user = User.find(params[:id])
        render json: user, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def create
        return render json: { error: 'Department not found' }, status: :not_found if invalid_department_id?

        user = User.new(user_params)

        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return render json: { error: 'Department not found' }, status: :not_found if invalid_department_id?

        user = User.find(params[:id])
        if user.update(user_params)
          render json: user, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        user = User.find(params[:id])
        user.destroy
        head :no_content
      end

      private

      def invalid_department_id?
        user_params[:department_id].present? && !Department.exists?(id: user_params[:department_id])
      end

      def user_params
        params.require(:user).permit(
          :name, :email, :company_email, :position, :function, :city,
          :company_tenure, :genre, :generation, :department_id
        )
      end
    end
  end
end
