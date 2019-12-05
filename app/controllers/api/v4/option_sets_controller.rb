# frozen_string_literal: true

class Api::V4::OptionSetsController < Api::V4::ApiController
  respond_to :json
  before_action :set_option_set, only: %i[update show destroy copy]

  def index
    @option_sets = OptionSet.all.includes(option_in_option_sets: [:option]).order(updated_at: :desc)
  end

  def show; end

  def create
    option_set = OptionSet.new(option_set_params)
    if option_set.save
      @option_set = option_set
      create_children
      render json: option_set, status: :created
    else
      render json: { errors: option_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @option_set.update_attributes(option_set_params)
      create_children
      head :ok
    else
      render json: { errors: @option_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @option_set.destroy
  end

  def copy
    new_option_set = @option_set.copy
    redirect_to action: 'show', id: new_option_set.id
  end

  private

  def set_option_set
    @option_set = OptionSet.includes(option_in_option_sets: [:option]).find(params[:id])
  end

  def create_children
    ActiveRecord::Base.transaction do
      params[:option_in_option_sets]&.each do |oios_params|
        oios = OptionInOptionSet.find_or_create_by(option_id: oios_params[:option_id], option_set_id: @option_set.id)
        oios.number_in_question = oios_params[:number_in_question]
        oios.special = oios_params[:special]
        oios.save
      end
    end
  end

  def option_set_params
    params.require(:option_set).permit(:title, :special, :instruction_id)
  end
end