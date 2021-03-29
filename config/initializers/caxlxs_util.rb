# frozen_string_literal: false

Axlsx::NumData.class_eval do
  attr_reader :pt
end

Axlsx::SimpleTypedList.class_eval do
  attr_reader :list
end
