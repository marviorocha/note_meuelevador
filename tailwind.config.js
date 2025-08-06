/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
    "./config/initializers/simple_form_tailwind.rb",
    "./lib/tasks/**/*.rake",
    "./lib/generators/**/*",
    "./lib/tasks/**/*.rake",
    "./vendor/bundle/**/*.rb",
    "./vendor/gems/**/*.rb"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
    require('@tailwindcss/typography')
  ],
  daisyui: {
    themes: ["light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", "winter"],
  },
} 