echo "Creating database..."
bin/rails db:setup

echo "Creating Procfile.dev"
cp Procfile.dev.sample Procfile.dev

echo "Done!"
