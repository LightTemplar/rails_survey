# frozen_string_literal: true

class Api::V4::TasksController < Api::V4::ApiController
  respond_to :json

  def index
    @tasks = Task.all.order(updated_at: :desc)
  end
end
