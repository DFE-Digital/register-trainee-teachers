echo "Creating database"
bin/rails db:setup
bin/rails db:seed example_data:generate

echo "Precompiling assets"
bin/rake assets:precompile

echo "Creating Procfile"
cp Procfile.dev.sample Procfile.dev

echo "Running Foreman to start the application"
foreman start -f Procfile.dev web

echo "Done!"
