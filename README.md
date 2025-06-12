# HasAttributes

Store arbitrary data and models in JSON or text fields within your ActiveRecord models - but treat them just like ordinary attributes.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add standard_procedure_has_attributes
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install standard_procedure_has_attributes
```

## Usage

Add a `text` field to your model.

```ruby 
add_column :my_items, :data, :text
```

Include the `HasAttributes` module, tell Rails to treat your field as a Hash that is stored as JSON, then define your attributes and models.

```ruby
class MyItem < ApplicationRecord
  serialize :data, type: Hash, coder: JSON 
  has_attribute :name, :string
  validates :name, presence: true 
  has_attribute :counter, :integer, default: 1 
  validates :counter, presence: true, numericality: { only_integer: true, greater_than: 0 }
  has_model :manager, "User"
  validates :manager, presence: true 
end
```

### If you're using Postgres
(or another database with JSON support)

Add a `json` or `jsonb` field to your model.

```ruby 
add_column :my_items, :data, :json
```

Include the `HasAttributes` module and define your attributes and models.

```ruby
class MyItem < ApplicationRecord
  has_attribute :name, :string
  validates :name, presence: true 
  has_attribute :counter, :integer, default: 1 
  validates :counter, presence: true, numericality: { only_integer: true, greater_than: 0 }
  has_model :manager, "User"
  validates :manager, presence: true 
end
```

### Defining attributes

The `has_attribute` declaration adds a new attribute on your Rails model, defining accessor methods that store your attribute in a Hash that is serialised to and from JSON in the database.  

It works the same way as the in-built `attribute` declaration; you give the attribute a name, optionally supply a [type](https://api.rubyonrails.org/classes/ActiveRecord/Type.html) (such as :string, :integer, :date) and default value.  This will be stored in a `text` (or `json`) field called `data` in your table.  However, if you want to store this data in a different field, you can also supply a `field_name` to the `has_attribute` declaration.  
Apart from storage, the attribute behaves just like any other attribute on your model, so you can use validations, reference it in callbacks or set its value with `create` or `update`.  It will also be marked as [dirty](https://api.rubyonrails.org/classes/ActiveModel/Dirty.html) when it is changed.  

### Defining models 

You can also store references to other models using the `has_model` declaration.  This stores a [GlobalID](https://github.com/rails/globalid) inside the data field, converting the reference back to a real model when needed.  The actual GlobalID is mangled slightly before it is stored, to provide compatibility with the [GlobalIdSerialiser](https://github.com/standard-procedure/global_id_serialiser), which also uses GlobalIDs to store references to models.  The difference with `has_model` is `has_model` reloads the model on-demand, whereas `GlobalIdSerialiser` loads all models from the data field when the record is loaded.  GlobalIdSerialiser also allows you to store your models within arrays or nested inside hashes - but you need to be careful about the performance implications if lots of models are stored.  

When using `has_model` you can optionally specify a class name (as a string).  If given, the model will be tested to make sure it is that class (or a subclass of it) and, if not the record is marked as invalid.  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/standard_procedure/has_attributes
