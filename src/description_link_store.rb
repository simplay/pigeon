require 'pstore'

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

  def self.find_all_including_key(name)
    instance.find_all_including_key(name)
  end

  def find_all_including_key(key_name)
    s = all_stored.select do |link_node|
      link_node.to_s.include? key_name
    end
    s.map(&:last)
  end

  def all_stored
    store.transaction do
      store.roots.map do |link|
        [link, store.fetch(link, [])]
      end
    end
  end

  def write(link, id)
    store.transaction do
      store[id] = link
      store.commit
    end
  end

  def delete(id)
    store.transaction do
      store.delete(id)
      store.commit
    end
  end

  def find(id)
    store.transaction do
      begin
        store.fetch(id)
      rescue
        nil
      end
    end
  end

  def store
    @file_db ||= PStore.new('data/desc_links.pstore')
  end

end
