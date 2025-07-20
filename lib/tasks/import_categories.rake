require "csv"

namespace :import do
  desc "Importa dados de categoria e subcategoria do db/dados_categorias.csv para a tabela categories e subcategories"
  task notes: :environment do
    file_path = Rails.root.join("db", "caetegories.csv")
    puts "Importando notas de #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      note = Category.new(
        # Ajuste os campos conforme as colunas do seu CSV e do modelo Note
        content: row["note_content"],
        user: row["User"],
        updated_at: row["updated_at"],
        # Adicione outros campos conforme necessário
      )
      if note.save
        puts "Nota criada: #{note.title}"
      else
        puts "Erro ao criar nota: #{note.errors.full_messages.join(', ')}"
      end
    end

    puts "Importação concluída."
  end
end
