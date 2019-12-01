# frozen_string_literal: true

class Api::V4::OptionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_option, only: %i[update show destroy]

  def index
    @options = Option.all.order(updated_at: :desc)
  end

  def show; end

  def create
    option = Option.new(option_params)
    if option.save
      render json: option, status: :created
    else
      render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @option.update_attributes(option_params)
  end

  def destroy
    respond_with @option.destroy
  end

  private

  def option_params
    params.require(:option).permit(:text, :identifier)
  end

  def set_option
    @option = Option.find(params[:id])
  end
end
