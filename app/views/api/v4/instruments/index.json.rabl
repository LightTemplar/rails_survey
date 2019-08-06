# frozen_string_literal: true

collection @instruments
cache ['v4-instruments', @instruments]

extends 'api/v4/instruments/show'
