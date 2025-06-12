# frozen_string_literal: true

RSpec.describe HasAttributes do
  it "has a version number" do
    expect(HasAttributes::VERSION).not_to be nil
  end

  context "defining attributes in the data field" do
    before do
      FileUtils.rm_rf "tmp/test.sqlite3"
      ActiveRecord::Base.establish_connection adapter: :sqlite3, database: "tmp/test.sqlite3"
      ActiveRecord::Base.connection.create_table :items do |t|
        t.string :name
        t.text :data
      end
      # standard:disable Lint/ConstantDefinitionInBlock
      class Item < ActiveRecord::Base
        include HasAttributes
        serialize :data, type: Hash, coder: GlobalIdSerialiser

        has_attribute :greeting, :string, default: "Hello"
        has_attribute :counter, :integer, default: 0
        has_attribute :friendly, :boolean, default: true

        def greet = "#{greeting} #{name}"
      end
      # standard:enable Lint/ConstantDefinitionInBlock
    end

    it "defines attributes with types and defaults" do
      item = Item.new name: "Alice"

      expect(item.greeting).to eq "Hello"
      expect(item.counter).to eq 0
    end

    it "allows attributes to be set" do
      item = Item.new name: "Bob", greeting: "Heyup", counter: 999

      expect(item.greeting).to eq "Heyup"
      expect(item.counter).to eq 999
    end

    it "marks an attribute as dirty" do
      item = Item.create! name: "Chandra", greeting: "Hi"

      item.greeting = "Hey there"

      expect(item.greeting_changed?).to be true

      item.save!

      expect(item.saved_change_to_greeting?).to be true
    end

    it "adds a question for boolean attributes" do
      item = Item.new friendly: false

      expect(item.friendly?).to be false
    end

    it "handles form field values for boolean attributes" do
      item = Item.new friendly: "0"

      expect(item.friendly?).to be false

      item.friendly = "1"

      expect(item.friendly?).to be true
    end
  end

  context "defining attributes in another field" do
    before do
      FileUtils.rm_rf "tmp/test.sqlite3"
      ActiveRecord::Base.establish_connection adapter: :sqlite3, database: "tmp/test.sqlite3"
      ActiveRecord::Base.connection.create_table :items do |t|
        t.string :name
        t.text :meta_data
      end
      # standard:disable Lint/ConstantDefinitionInBlock
      class Item < ActiveRecord::Base
        include HasAttributes
        serialize :meta_data, type: Hash, coder: GlobalIdSerialiser

        has_attribute :greeting, :string, default: "Hello", field_name: "meta_data"
        has_attribute :counter, :integer, default: 0, field_name: "meta_data"
        has_attribute :friendly, :boolean, default: true, field_name: "meta_data"

        def greet = "#{greeting} #{name}"
      end
      # standard:enable Lint/ConstantDefinitionInBlock
    end

    it "defines attributes with types and defaults" do
      item = Item.new name: "Alice"

      expect(item.greeting).to eq "Hello"
      expect(item.counter).to eq 0
    end

    it "allows attributes to be set" do
      item = Item.new name: "Bob", greeting: "Heyup", counter: 999

      expect(item.greeting).to eq "Heyup"
      expect(item.counter).to eq 999
    end

    it "marks an attribute as dirty" do
      item = Item.create! name: "Chandra", greeting: "Hi"

      item.greeting = "Hey there"

      expect(item.greeting_changed?).to be true

      item.save!

      expect(item.saved_change_to_greeting?).to be true
    end

    it "adds a question for boolean attributes" do
      item = Item.new friendly: false

      expect(item.friendly?).to be false
    end

    it "handles form field values for boolean attributes" do
      item = Item.new friendly: "0"

      expect(item.friendly?).to be false

      item.friendly = "1"

      expect(item.friendly?).to be true
    end
  end
end
