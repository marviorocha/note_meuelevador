class Note < ApplicationRecord
  belongs_to :author
  belongs_to :subcategory
  has_many :note_tags
  has_many :tags, through: :note_tags

  include AlgoliaSearch

  algoliasearch do
    # 1. Attributes from the Note model itself
    attributes :subcategory, :content, :hierarchicalCategories # Add any other attributes you want to index from Note

    attribute :hierarchicalCategories do
        {
            lvl0: subcategory.category.name,
            lvl1: "#{subcategory.category.name} > #{subcategory.name}"
        }
        end

    attribute :author do
      {
        id: author.id,
        name: author.name # Assuming Author has a 'name' attribute

      }
    end

    attribute :category do
      {
        id: subcategory.category.id,
        name: subcategory.category.name
      }
    end

    attribute :subcategory do
      {
        id: subcategory.id,
        name: subcategory.name # Assuming Subcategory has a 'name' attribute
      }
    end


    attribute :tags do
      tags.map do |tag|
        {
          id: tag.id,
          name: tag.name
        }
      end
    end


    searchableAttributes [
      "content",
      "author.name",
      "subcategory.name",
      "subcategory.category.name",
      "tags.name"
    ]

    attributesForFaceting [
      "author.name",
      "subcategory.category.name",
      "subcategory.name",
      "tags.name",
      "hierarchicalCategories.lvl0",
      "hierarchicalCategories.lvl1"
    ]

    ranking [ "words", "typo", "attribute" ] # Example ranking
  end
end
