# frozen_string_literal: true

collection @projects
cache ['v4-projects', @projects]

extends 'api/v4/projects/show'
