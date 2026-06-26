class Note < ApplicationRecord
  belongs_to :author
  belongs_to :subcategory
  has_many :note_tags
  has_many :tags, through: :note_tags

 enum :status, { revisar: 0, ok: 1, arquivado: 2 }
  after_commit :sync_typesense
  include AlgoliaSearch

  algoliasearch disable_indexing: Rails.env.test? || ENV["ALGOLIA_ADMIN_API_KEY"].blank? do
    # Attributes to be indexed
    attributes :content, :status

    attribute :hierarchicalCategories do
      if subcategory&.category
        {
          lvl0: subcategory.category.name,
          lvl1: "#{subcategory.category.name} > #{subcategory.name}"
        }
      end
    end

    attribute :author do
      if author
        {
          id: author.id,
          name: author.name
        }
      end
    end

    attribute :category do
      if subcategory&.category
        {
          id: subcategory.category.id,
          name: subcategory.category.name
        }
      end
    end

    attribute :subcategory do
      if subcategory
        {
          id: subcategory.id,
          name: subcategory.name
        }
      end
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
      "status",
      "author.name",
      "subcategory.name",
      "subcategory.category.name",
      "tags.name"
    ]

    attributesForFaceting [
      "category.name",
      "author.name",
      "subcategory.category.name",
      "subcategory.name",
      "tags.name",
      "status",
      "hierarchicalCategories.lvl0",
      "hierarchicalCategories.lvl1"
    ]

    ranking [ "words", "typo", "attribute" ]
  end
end
