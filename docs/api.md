
# API Technical Guidance

## Versioning

API versions are incremented semantically as follows:

- `v0.1` (draft version)
- `v1.0-pre` (pre-release candidate of first major release)
- `v2025.0-rc` (release candidate of first major release)

We namespace at the module level and indicate the major and minor version in the directory with underscores:

```ruby
# app/models/api/v0_1/trainee_attributes.rb

module Api
  module V01
    class TraineeAttributes
      # code ...
    end
  end
end
```

## Generating New API Code

A utility service can be called via rake task to generate new API code:

```sh
rake api:generate_new_version[v0.1,v2025.0-rc]
```

This will copy all API services, models, and serializers into a new namespace, properly defining inheritance from the previous version. For example:

```ruby
# app/models/api/v0_1/trainee_attributes.rb

module Api
  module V01
    class TraineeAttributes
      # code ...
    end
  end
end
```

Will be copied to:

```ruby
# app/models/api/v2025_0_rc/trainee_attributes.rb

module Api
  module V20250Rc
    class TraineeAttributes < Api::V01::TraineeAttributes
    end
  end
end
```

> _note: Actual code is not copied over, only module and class definitions_

## Generating New API Specs

Specs can also be generated using a similar rake task:

```sh
rake api:generate_new_spec_version[v0.1,v2025.0-rc]
```

This generator focuses on copying all request specs for the existing version and performing a find-and-replace for all instances of `vX.X` (in its various forms) to the new version.

### Notes

- Ensure that the version format provided is `vx.x` (for example `v0.1` or `v2025.0-rc`).
- The generators handle version conversion and inheritance, making it easy to create new versions of the API and corresponding specs.

This documentation should provide clear guidance on how to use the versioning system and the utility services for generating new API code and specs.
