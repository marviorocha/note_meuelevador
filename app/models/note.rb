class Note < ApplicationRecord

  belongs_to :author
  belongs_to :subcategory
  has_many :note_tags
  has_many :tags, through: :note_tags

  include AlgoliaSearch

  algoliasearch do
    # 1. Attributes from the Note model itself
    attributes :subcategory, :content # Add any other attributes you want to index from Note


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

    # 3. Include data from `has_many :through` associations
    # For `has_many` or `has_many :through`, you'll typically want an array of data.
    attribute :tags do
      tags.map do |tag|
        {
          id: tag.id,
          name: tag.name  
        }
      end
    end

    # 4. Define searchable attributes
    # Decide which attributes (including nested ones) you want to be searchable.
    # Use dot notation for nested attributes (e.g., 'author.name').
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
      "tags.name"
    ]


    ranking [ "words", "typo", "attribute" ] # Example ranking
    # You could also add: 'asc(author.name)' or 'asc(subcategory.name)' if you want to rank by them.

    # 7. Consider `after_commit` for real-time updates (often the default)
    # The `algoliasearch-rails` gem automatically uses `after_commit` hooks
    # to reindex records when they are created, updated, or destroyed.
    # However, changes to *associated* records (e.g., updating an author's name)
    # won't automatically reindex the `Note` unless you explicitly tell it to.
    #
    # To reindex the `Note` when an associated `Author` or `Subcategory` changes:
    # Add `touch: true` to your `belongs_to` associations if you want the `Note`
    # to be updated (and thus reindexed by Algolia) when the associated record changes.

    # belongs_to :subcategory, touch: true

    # For `has_many` (or `has_many :through`), you might need `after_save` or `after_commit`
    # callbacks in the associated models to trigger re-indexing of the main model.
    # Example in `app/models/tag.rb`:
    # class Tag < ApplicationRecord
    #   has_many :note_tags
    #   has_many :notes, through: :note_tags
    #   after_save { notes.each(&:algolia_reindex!) } # Reindex associated notes when a tag changes
    # end
    # Note: `algolia_reindex!` is the method provided by the gem.
    # The `touch: true` on `belongs_to` is generally preferred if it fits your use case,
    # as it's more idiomatic Rails. For `has_many`, you often need an explicit callback.
  end
end
