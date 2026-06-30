namespace :typesense do
  desc "Gera uma Search-Only API Key no Typesense e salva no config/application.yml"
  task generate_search_key: :environment do
    puts "🔑 Gerando Search-Only Key no Typesense..."

    begin
      key = TYPESENSE_CLIENT.keys.create({
        "description" => "Search-only key for InstantSearch.js front-end",
        "actions"     => ["documents:search"],
        "collections" => ["notes"]
      })

      search_key = key["value"]
      puts "✅ Key gerada: #{search_key}"

      yml_path = Rails.root.join("config", "application.yml")
      content  = File.read(yml_path)

      if content.match?(/^TYPESENSE_SEARCH_KEY:/)
        content.gsub!(/^TYPESENSE_SEARCH_KEY:.*$/, "TYPESENSE_SEARCH_KEY: \"#{search_key}\"")
        puts "✅ TYPESENSE_SEARCH_KEY atualizada no application.yml"
      else
        content << "\nTYPESENSE_SEARCH_KEY: \"#{search_key}\"\n"
        puts "✅ TYPESENSE_SEARCH_KEY adicionada ao application.yml"
      end

      File.write(yml_path, content)
      puts "🎉 Pronto! Reinicie o servidor Rails para aplicar a nova key."
    rescue => e
      puts "❌ Erro: #{e.message}"
      puts e.backtrace.first(3).join("\n")
    end
  end

  desc "Lista as API Keys existentes no Typesense"
  task list_keys: :environment do
    keys = TYPESENSE_CLIENT.keys.retrieve
    puts "🔑 #{keys['keys'].length} key(s) encontrada(s):"
    keys["keys"].each do |k|
      puts "  - ID: #{k['id']} | #{k['description']} | Actions: #{k['actions'].join(', ')}"
    end
  end

  desc "Reindexa todas as notas no Typesense"
  task reindex: :environment do
    puts "🔄 Reindexando todas as notas..."
    Note.reindex_all
    puts "✅ Reindexação concluída!"
  end
end
