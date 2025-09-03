# frozen_string_literal: true

require "rails_helper"

path = Rails.root.join("reviewing/spec")
Dir.glob("#{path}/**/*_spec.rb") { |file| require file }
