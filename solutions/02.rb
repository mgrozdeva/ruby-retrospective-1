class Song
  attr_accessor :name, :artist, :genre, :subgenre, :tags
  
  def initialize(name, artist, genre, subgenre, tags)
    @name, @artist, @genre, @subgenre = name, artist, genre, subgenre
    @tags = tags ? tags.split(",").each { |tag| tag.strip! } : []
    @tags << genre.downcase
    @tags << subgenre.downcase if subgenre
  end
  
  def add_tags(new_tags)
    @tags = @tags | new_tags
  end
  
 
   def matches_tags?(tags)
    tags = Array(tags)
    included = tags.reject { |x| x.end_with? "!" }
    no_included = tags.select { |x| x.end_with? "!" }
    no_included.map! { |tag| tag.delete("!") }
    if included.all? { |tag| @tags.include? tag }
      return no_included.none? { |tag| @tags.include? tag }
    end
    false
  end
  def matches?(criteria)
    filters = {
      :name => @name == criteria[:name],
      :artist => @artist == criteria[:artist],
      :tags => (matches_tags? criteria[:tags]),
      :filter => (criteria[:filter] and criteria[:filter].(self)),
    }
    criteria.map { |key, value| filters[key] }.all?
  end
end
  