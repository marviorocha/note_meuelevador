class Note < ApplicationRecord
  belongs_to :author
  belongs_to :subcategory
  has_many :note_tags
  has_many :tags, through: :note_tags

  enum :status, { revisar: 0, ok: 1, arquivado: 2, revisado_por_pablo: 3 }

  after_commit :sync_typesense, on: [ :create, :update ]
  after_commit :remove_from_typesense, on: [ :destroy ]

  def self.search(query, options = {})
    query = "*" if query.blank?

    search_parameters = {
      "q" => query,
      "query_by" => "content,author.name,category.name,subcategory.name,tags"
    }

    if options[:filters].present?
      search_parameters["filter_by"] = options[:filters]
    end

    begin
      results = TYPESENSE_CLIENT.collections["notes"].documents.search(search_parameters)

      note_ids = results["hits"].map { |hit| hit["document"]["id"].to_i }

      if note_ids.any?
        Note.where(id: note_ids).in_order_of(:id, note_ids)
      else
        Note.none
      end
    rescue Typesense::Error::ObjectNotFound
      Note.none
    end
  end

  def typesense_document
    {
      "id" => id.to_s,
      "content" => content.to_s,
      "author.name" => author&.name.to_s,
      "category.name" => subcategory&.category&.name.to_s,
      "subcategory.name" => subcategory&.name.to_s,
      "status" => status.to_s,
      "tags" => tags.map(&:name)
    }
  end

  private

  def sync_typesense
    begin
      TYPESENSE_CLIENT.collections["notes"].documents.upsert(typesense_document)
    rescue Typesense::Error::ObjectNotFound
      self.class.create_typesense_collection
      TYPESENSE_CLIENT.collections["notes"].documents.upsert(typesense_document)
    rescue => e
      Rails.logger.error "Typesense sync failed: #{e.message}"
    end
  end

  def remove_from_typesense
    begin
      TYPESENSE_CLIENT.collections["notes"].documents[id.to_s].delete
    rescue => e
      Rails.logger.error "Typesense delete failed: #{e.message}"
    end
  end

  def self.create_typesense_collection
    schema = {
      "name" => "notes",
      "fields" => [
        { "name" => "content", "type" => "string" },
        { "name" => "author.name", "type" => "string", "facet" => true },
        { "name" => "category.name", "type" => "string", "facet" => true },
        { "name" => "subcategory.name", "type" => "string", "facet" => true },
        { "name" => "status", "type" => "string", "facet" => true },
        { "name" => "tags", "type" => "string[]", "facet" => true }
      ]
    }
    begin
      TYPESENSE_CLIENT.collections["notes"].delete
    rescue Typesense::Error::ObjectNotFound
      # Ignore
    end
    TYPESENSE_CLIENT.collections.create(schema)
  end

  def self.reindex_all
    create_typesense_collection

    find_in_batches(batch_size: 100) do |notes|
      documents = notes.map(&:typesense_document)
      TYPESENSE_CLIENT.collections["notes"].documents.import(documents)
    end
  end
end
