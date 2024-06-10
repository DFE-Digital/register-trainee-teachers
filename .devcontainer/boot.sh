echo "Creating database..."
bin/rails db:setup
bin/rails db:seed example_data:generate

echo "Creating Procfile.dev"
cp Procfile.dev.sample Procfile.dev

echo "Done!"
