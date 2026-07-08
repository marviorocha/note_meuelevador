require "csv"

namespace :import do
  desc "Importa categorias e subcategorias do db/dados_notas.csv (ignora duplicatas)"
  task categories: :environment do
    file_path = Rails.root.join("db", "dados_notas.csv")
    puts "Importando categorias e subcategorias de #{file_path}..."

    cat_count = 0
    sub_count = 0

    CSV.foreach(file_path, headers: true) do |row|
      cat_name = row["categoria"].to_s.strip
      sub_name = row["subcategoria"].to_s.strip

      next if cat_name.blank? || sub_name.blank?

      # Busca case-insensitive antes de criar para evitar duplicata
      cat = Category.where("LOWER(name) = ?", cat_name.downcase).first_or_initialize(name: cat_name)
      if cat.new_record?
        cat.save!
        cat_count += 1
        puts "  [Nova] Categoria: #{cat.name}"
      end

      sub = Subcategory.where("LOWER(name) = ? AND category_id = ?", sub_name.downcase, cat.id).first_or_initialize(name: sub_name, category: cat)
      if sub.new_record?
        sub.save!
        sub_count += 1
        puts "  [Nova] Subcategoria: #{sub.name} (#{cat.name})"
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "  [Ignorado] #{e.message} | linha: #{row.inspect}"
    rescue ActiveRecord::RecordNotUnique => e
      puts "  [Duplicata ignorada] #{e.message}"
    rescue => e
      puts "  [Erro] #{row.inspect} - #{e.message}"
    end

    puts "\nImportação concluída: #{cat_count} categorias e #{sub_count} subcategorias criadas."
  end
end
