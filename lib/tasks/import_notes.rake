require "csv"

namespace :import do
  desc "Importa dados do db/dados_notas.csv para a tabela notes"
  task notes: :environment do
    file_path = Rails.root.join("db", "dados_notas.csv")
    puts "Importando notas de #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      note = Note.new(
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
