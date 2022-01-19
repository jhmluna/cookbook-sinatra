# frozen_string_literal: true

# Hold recipe instances.
class Recipe
  attr_reader :name, :description, :rating, :prep_time

  def initialize(name, description, rating, prep_time, done = false)
    @name = name
    @description = description
    @rating = rating
    @prep_time = prep_time
    @done = init_done(done)
  end

  def init_done(done_arg)
    done_arg.eql?('true')
  end

  def done?
    @done
  end

  def mark_as_done!
    @done = true
  end
end
