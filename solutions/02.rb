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
  
 
   def matches_tags?(tags)class Song
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
    wanted = tags.reject { |x| x.end_with? "!" }
    unwanted = tags.select { |x| x.end_with? "!" }
    unwanted.map! { |tag| tag.delete("!") }
    if wanted.all? { |tag| @tags.include? tag }
      return unwanted.none? { |tag| @tags.include? tag }
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
  
class Collection
  attr_reader :songs_container
  
  def parse_song(song_as_string)
    collector = []
    song_as_string.each_line do |song| song = song.split('.').map(&:strip) 
      if (song[2].include? ",") 
        genre, subgenre = song[2].split(",")[0], song[2].split(",")[1].strip!
        collector << Song.new(song[0],song[1], genre, subgenre, song[3])
      else 
        collector << Song.new(song[0], song[1], song[2], nil, song[3])
      end
    end
    collector
  end
  
  def apply_tag(a_tag)
    @songs_container.select { |s| s.artist ==a_tag.first }.each do |song|
      song.add_tags a_tag[1]
    end
  end
  
  def initialize(songs_as_string, artist_tags)
    @songs_container = parse_song(songs_as_string)
    artist_tags.each { |item| apply_tag(item)}
  end	 
  
 
  def find(criteria)
    @songs_container.select { |song| song.matches?(criteria) }
  end
end

#map vmesto each member
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
  