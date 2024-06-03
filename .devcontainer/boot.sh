echo "Creating database..."
bin/rails db:setup

echo "Creating Procfile.dev"
cp Procfile.dev.example Procfile.dev

echo "Done!"
