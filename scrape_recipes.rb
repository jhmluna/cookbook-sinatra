require 'nokogiri'
require 'open-uri'

# Scrap Service
module ScrapeServices
  # Gets a list of the first five recipes.
  class ScrapeAllRecipes
    def initialize(keyword)
      @keyword = keyword
    end

    # Return a list of `Recipe` built from scraping the web.
    def call
      # Creates a new Nokogiri OBJECT
      url = 'https://www.allrecipes.com/search/results/?search='.concat(@keyword)
      doc = Nokogiri::HTML(URI.open(url).read, nil, 'utf-8')
      # Initialize the array that will save the imported recipes
      get_recipes(doc).take(5)
    end

    private

    # From the Nokogiri object, extract the title, description, rating and URL
    def get_recipes(html_doc)
      imported_recipes = []
      # Ask Nokogiri object to give the HTML element MATCHES
      html_doc.search('.card__detailsContainer').each do |card_container|
        title = card_container.search('h3.card__title').text.strip
        rating = card_container.search('.review-star-text')
                               .text.strip.delete_prefix('Rating: ').delete_suffix(' stars').to_f
        recipe_url = card_container.search('a.card__titleLink').attribute('href').value
        imported_recipes << [title, rating, recipe_url]
      end
      imported_recipes
    end
  end

  # Gets the recipe data
  class ScrapeSelectedRecipe
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      imported_recipes = []
      doc = Nokogiri::HTML(URI.open(@recipe).read, nil, 'utf-8')
      title = doc.css('h1').text.strip
      description = doc.css('div.recipe-summary p.margin-0-auto').text.strip
      rating = doc.css('span.review-star-text').text.strip.delete_prefix('Rating: ').delete_suffix(' stars').to_f
      prep_time = get_prep_time(doc)
      imported_recipes.unshift(title, description, rating, prep_time)
      imported_recipes
    end

    private

    def get_prep_time(doc)
      recipe_info = ''
      # Search for class that contain total time
      doc.search('div.recipe-meta-item').each do |item|
        if item.search('.recipe-meta-item-header').text == 'total:'
          recipe_info = item.search('.recipe-meta-item-body').text.strip
        end
      end
      recipe_info
    end
  end
end
