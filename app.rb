require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry-byebug'
require 'better_errors'
require_relative 'cookbook'
require_relative 'scrape_recipes'

# Load csv file that store recipes
csv_file = File.join(__dir__, 'recipes.csv')
# 1. Fetch recipes from repo
cookbook = Cookbook.new(csv_file)

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('__dir__', __FILE__)
end

get '/' do
  @recipes = cookbook.all
  erb :index
end

get '/mark/:id' do
  cookbook.mark_as_done!(params[:id].to_i)
  redirect to('/')
end

get '/new' do
  erb :new
end

post '/recipes' do
  recipe = Recipe.new(params[:name], params[:description], params[:rating], "#{params[:prep_time]} mins")
  cookbook.add_recipe(recipe)
  redirect to('/')
end

get '/destroy/:id' do
  cookbook.remove_recipe(params[:id].to_i)
  redirect to('/')
end

get '/import' do
  erb :import
end

get '/scrap' do
  # 1. Search and scrap the results
  @online_recipes = ScrapeServices::ScrapeAllRecipes.new(params[:keyword]).call
  erb :scrap
end

post '/scrap' do
  @scraping = ScrapeServices::ScrapeSelectedRecipe.new(params[:recipe]).call
  recipe = Recipe.new(@scraping[0], @scraping[1], @scraping[2], @scraping[3])
  cookbook.add_recipe(recipe)
  redirect to('/')
end
