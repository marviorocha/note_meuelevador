namespace :vite do
  desc "Build Vite assets for production"
  task build: :environment do
    puts "Building Vite assets..."
    system("npm run build") || system("npx vite build")
    puts "Vite assets built successfully!"
  end

  desc "Clean Vite assets"
  task clean: :environment do
    puts "Cleaning Vite assets..."
    FileUtils.rm_rf(Rails.root.join("public/vite"))
    puts "Vite assets cleaned!"
  end

  desc "Install npm dependencies"
  task install: :environment do
    puts "Installing npm dependencies..."
    system("npm install")
    puts "npm dependencies installed!"
  end
end 