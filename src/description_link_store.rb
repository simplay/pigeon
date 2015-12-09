require 'pstore'

# DescriptionLinkStore stores all links - mainly LabeledLinkText instances -
# shown in a target channel description.
# They are used in a particular Layout instance. Such links are managed by a unique identifier.
# E.g. all minecraft Links are prefixed by "mc_".
class DescriptionLinkStore

  def self.instance
    @instance ||= DescriptionLinkStore.new
  end

  def self.all_stored
    instance.all_stored
  end

  def self.write(link, id)
    instance.write(link, id)
  end

  def self.delete(id)
    instance.delete(id)
  end

  def self.find(id)
    instance.find(id)
  end

  def self.find_all_including_key(name, return_key_value_pair=false)
    instance.find_all_including_key(name, return_key_value_pair)
  end

  # Retrieve all entities keys which have a match between their identifier and a provided name.
  #
  # @example
  #   #find_all_including_key("mc", true)
  #   returns LabeledLinkText that match mc plus their identifiers.
  #
  # @info: Note that by default only their identifier is returned, by passing
  #   return_key_value_pair = true, the whole entity will be returned.
  # @param key_name [String] substring used for matching db entitiy ids.
  # @return_key_value_pair [Boolean] optional, should the whole entity be returned.
  # @return [Array] list of entities that match the input.
  def find_all_including_key(key_name, return_key_value_pair=false)
    s = all_stored.select do |link_node|
      link_node.to_s.include? key_name
    end
    return s if return_key_value_pair
    s.map(&:last)
  end

  # Return every stored entity.
  #
  # @return [Array<ID, Array<LabeledLinkText.new>>] list of entities.
  def all_stored
    store.transaction do
      store.roots.map do |link|
        [link, store.fetch(link, [])]
      end
    end
  end

  # Store or update a link in the db that has an given id.
  #
  # @example
  #   link = LabeledLinkText.new("Foobar", "www.foobar.com")
  #   DescriptionLinkStore.write(link, :foobar_id)
  #
  # @param link [LabeledLinkText] a text link
  # @param id [Symbol] identifier of this link element.
  def write(link, id)
    store.transaction do
      store[id] = link
      store.commit
    end
  end

  # Delete a link by id.
  #
  # @example
  #   DescriptionLinkStore.delete(:foobar_id)
  #
  # @param id [Symbol] identifier of an existing entity.
  def delete(id)
    store.transaction do
      store.delete(id)
      store.commit
    end
  end

  # Fetch a entity by its identifier.
  #
  # @return [LabeledLinkText, nil] returns a stored link in case it exists.
  def find(id)
    store.transaction do
      begin
        store.fetch(id)
      rescue
        nil
      end
    end
  end

  # Returns the file db.
  def store
    @file_db ||= PStore.new('data/desc_links.pstore')
  end

end
