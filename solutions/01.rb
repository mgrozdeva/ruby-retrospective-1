class Array
# Ex.1
  def to_hash
    inject({}) do |hash, value| 
      hash[value[0]] = value[1] 
      hash
    end
	end
# Ex.2	
	def index_by( &block )
		inject({}) do |hash,elem|
      hash[yield elem] = elem
      hash 
    end
	end	
# Ex.3 
	def subarray_count(subarray)
		each_cons(subarray.length).count(subarray)
	end
# Ex.4	
	def occurences_count
		output = Hash.new(0)
		each { |x| output[x] = count(x) }	
		output
	end	
end
