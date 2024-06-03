echo "Creating database..."
bin/rails db:setup

echo "Starting site..."
bundle exec rails s -p 5001 &
yarn build --watch &
yarn build:css --watch &

echo "Done!"
