# Active Record Encryption Setup

The service uses AR encryption for certain information in the database.

Keys are generated using the command `bin/rails db:encryption:init`

Further details are available [here](https://guides.rubyonrails.org/active_record_encryption.html#setup)

These are stored in the services key store and fetched in `config/application.rb`.
