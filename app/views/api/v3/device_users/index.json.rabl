# frozen_string_literal: true

collection @device_users
cache ['v3-device-users', @device_users]
attributes :id, :username, :name, :password_digest, :active
