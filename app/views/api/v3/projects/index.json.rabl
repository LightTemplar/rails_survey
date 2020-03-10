# frozen_string_literal: true

collection @projects
cache ['v3-projects', @projects]

attributes :id, :name, :description
