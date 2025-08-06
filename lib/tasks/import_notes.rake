require "csv"

namespace :import do
  desc "Importa dados do db/dados_notas.csv para a tabela notes"
  task notes: :environment do
    file_path = Rails.root.join("db", "dados_notas.csv")
    puts "Importando notas de #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      author = Author.find_or_create_by!(name: row["Author"])
      cat = Category.find_or_create_by!(name: row["categoria"])

      status_text = row["status"]

      status = case status_text

      when "Revisar"
        :revisar
      when "Ok"
        :ok
      when "Arquivado"
        :arquivado
      else
        :revisar
      end

      sub = Subcategory.find_or_create_by!(name: row["subcategoria"], category: cat)
      tag_names = row["tags"].to_s.split(",").map(&:strip)
      tags = tag_names.map { |t| Tag.find_or_create_by!(name: t) }

      note = Note.create!(

        subcategory: sub,
        author: author,
        status: status,
        content: row["note_content"],
        characters: row["Caracteres"].to_i,
        is_new: row["is_new"].to_s.downcase == "true"
      )

      note.tags << tags
      puts "Nota criada: #{note.id} - #{note.content.truncate(30)}"
    rescue => e
      puts "Erro ao importar linha: #{row.inspect} - #{e.message}"
    end

    puts "Importação concluída."
  end
end
