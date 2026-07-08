require "csv"

namespace :import do
  desc "Importa notas do db/dados_notas.csv para a tabela notes (requer categorias já importadas)"
  task notes: :environment do
    file_path = Rails.root.join("db", "dados_notas.csv")
    puts "Importando notas de #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      author = Author.find_or_create_by!(name: row["Author"].to_s.strip)
      cat_name = row["categoria"].to_s.strip
      cat = Category.where("LOWER(name) = ?", cat_name.downcase).first!


      status_text = row["status"]

      status = case status_text
      when "Revisar"
        :revisar
      when "Ok"
        :ok
      when "Arquivado"
        :arquivado
      when "Revisado por Pablo"
        :revisado_por_pablo
      when ""
        :revisar
      else
        :revisar
      end

      sub_name = row["subcategoria"].to_s.strip
      sub = Subcategory.where("LOWER(name) = ? AND category_id = ?", sub_name.downcase, cat.id).first!
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
