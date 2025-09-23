echo "Creating database"
bin/rails db:setup
bin/rails db:seed example_data:generate_light

echo "Precompiling assets"
bin/rake assets:precompile

echo "Creating Procfile"
cp Procfile.dev.sample Procfile.dev

echo "Running Foreman to start the application"
foreman start -f Procfile.dev web &

echo "Running Foreman to start the docs"
cd tech_docs
bundle install
bundle exec middleman serve
cd ..

echo "Done!"
wait %1
