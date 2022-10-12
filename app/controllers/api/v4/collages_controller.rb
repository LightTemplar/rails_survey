# frozen_string_literal: true

class Api::V4::CollagesController < Api::V4::ApiController
  respond_to :json

  def index
    @collages = Collage.all.order(updated_at: :desc)
  end
end
