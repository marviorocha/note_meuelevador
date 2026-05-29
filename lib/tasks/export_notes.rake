require "csv"

namespace :export do
  desc "Exporta dados da tabela notes para db/dados_notas.csv"
  task notes: :environment do
    file_path = Rails.root.join("db", "dados_notas.csv")
    puts "Exportando notas para #{file_path}..."

    headers = ["Author", "categoria", "subcategoria", "status", "note_content", "Caracteres", "is_new", "tags"]

    CSV.open(file_path, "wb", write_headers: true, headers: headers) do |csv|
      Note.includes(:author, :subcategory, :tags).find_each do |note|
        status_text = case note.status
                      when "revisar" then "Revisar"
                      when "ok" then "Ok"
                      when "arquivado" then "Arquivado"
                      else "Revisar"
                      end

        csv << [
          note.author.name,
          note.subcategory.category.name,
          note.subcategory.name,
          status_text,
          note.content,
          note.characters,
          note.is_new,
          note.tags.map(&:name).join(", ")
        ]
      end
    end

    puts "Exportação concluída."
  end
end
