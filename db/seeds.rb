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

# Category.create(name: 'Máquina de Tração')
# Category.create(name: 'Casa de Máquinas')
# Category.create(name: 'Freio de Segurança')
# Category.create(name: 'Cabine')
# Category.create(name: 'Quadro de Força')
# Category.create(name: 'Quadro de Comando')
# Category.create(name: 'Caixa de Corrida')
# Category.create(name: 'Porta de Pavimento')
# Category.create(name: 'Poço')

author = Author.create!(name: "Eliseu")
cat = Category.create!(name: "Máquina de Tração")
status = Note.status
sub = Subcategory.create!(name: "Cabos de Tração", category: cat)
tags = [ "falta trava de segurança", "presilha", "norma" ].map { |t| Tag.find_or_create_by!(name: t) }

note = Note.create!(
  updated_at: "2014-06-18",
  subcategory: sub,
  status: status,
  author: author,
  content: "A braçadeira de um dos cabos de aço de tração do elevador está fixado do lado errado.
Tal irregularidade reduz a força de fixação e pode levar ao escorregamento, comprometendo a segurança do equipamento.
Necessita regularização. NM7192 A-5.3.4 Quarta fase Colocar as braçadeiras para cabos (as porcas devem ficar no lado da ponta do cabo não cortado).",
  characters: 205,
  is_new: false
)

note.tags << tags


print "Finished import seed database \n"
