# frozen_string_literal: true

require 'csv'
require_relative 'recipe'

# Repository for recipes
class Cookbook
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @recipes = []
    load_recipe_from_csv
  end

  # Retorna o array com as instancias da classe Recipe
  def all
    @recipes
  end

  # Adiciona uma instancia de recipe ao array recipes e atualiza o arquivo csv
  def add_recipe(recipe)
    @recipes << recipe
    update_csv
  end

  # Deleta a instancia de recipe ao array recipes e atualiza o arquivo csv
  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
    update_csv
  end

  def mark_as_done!(index)
    @recipes[index].mark_as_done!
    update_csv
  end

  private

  # Carrega o arquivo csv e salva como instancia de recipe no array @recipes
  def load_recipe_from_csv
    csv_recipe = CSV.read(@csv_file_path)
    csv_recipe.each do |r|
      @recipes << Recipe.new(r[0], r[1], r[2], r[3], r[4])
    end
  end

  # Atualiz o arquivo csv, guardando o nome e a descricao da classe Recipe
  def update_csv
    CSV.open(@csv_file_path, 'wb') do |csv|
      @recipes.each do |recipe_to_csv|
        csv << [recipe_to_csv.name, recipe_to_csv.description, recipe_to_csv.rating,
                recipe_to_csv.prep_time, recipe_to_csv.done?]
      end
    end
  end
end
