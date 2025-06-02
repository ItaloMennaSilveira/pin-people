module Api
  module V1
    class DepartmentsController < ApplicationController
      def index
        departments = Department
                      .by_level(params[:level])
                      .page(params[:page])
                      .per(params[:per_page] || 20)

        render json: {
          departments: departments,
          meta: {
            current_page: departments.current_page,
            total_pages: departments.total_pages,
            total_count: departments.total_count
          }
        }, status: :ok
      end

      def show
        department = Department.find(params[:id])
        root = department.root_department

        render json: root.as_json(
          include: {
            sub_departments: {
              include: {
                sub_departments: {
                  include: :sub_departments
                }
              }
            }
          }
        ), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Department not found' }, status: :not_found
      end

      def create
        department = Department.new(department_params)

        if department.company? && department.parent_id.present?
          return render json: { error: 'Company-level departments cannot have a parent' }, status: :unprocessable_entity
        end

        if department.save
          render json: department, status: :created
        else
          render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        department = Department.find(params[:id])

        if department_params[:level] == 'company' && department_params[:parent_id].present?
          return render json: { error: 'Company-level departments cannot have a parent' }, status: :unprocessable_entity
        end

        if department.update(department_params)
          render json: department, status: :ok
        else
          render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Department not found' }, status: :not_found
      end

      def destroy
        department = Department.find(params[:id])
        department.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Department not found' }, status: :not_found
      end

      private

      def department_params
        params.require(:department).permit(:name, :level, :parent_id)
      end
    end
  end
end
