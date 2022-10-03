# frozen_string_literal: true

class Api::V4::OptionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_option, only: %i[update show destroy]

  def index
    @options = Option.all.order(updated_at: :desc)
  end

  def show; end

  def create
    if (resource = Option.only_deleted.find_by(identifier: params[:option][:identifier]))
      resource.update(deleted_at: nil, text: params[:option][:text])
      redirect_to action: 'show', id: resource.id
    else
      option = Option.new(option_params)
      if option.save
        render json: option, status: :created
      else
        render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    if @option.update_attributes(option_params)
      render json: @option, status: :accepted
    else
      render json: { errors: @option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @option.destroy
  end

  private

  def option_params
    params.require(:option).permit(:text, :identifier, :text_one, :text_two)
  end

  def set_option
    @option = Option.find(params[:id])
  end
end
