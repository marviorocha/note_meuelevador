# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


#########  Category default create ########
print "Creating default categories...\n"

Category.create(name: 'Máquina de Tração')
Category.create(name: 'Casa de Máquinas')
Category.create(name: 'Freio de Segurança')
Category.create(name: 'Cabine')
Category.create(name: 'Quadro de Força')
Category.create(name: 'Quadro de Comando')
Category.create(name: 'Caixa de Corrida')
Category.create(name: 'Porta de Pavimento')
Category.create(name: 'Poço')

print "Finished import seed database \n"
