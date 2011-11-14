require 'bigdecimal'
require 'bigdecimal/util'

class Inventory 
  attr_accessor :items, :coupons
  
  def initialize()
    @items = Array.new
    @coupons = Array.new
  end
  
  def get_item(name)
    @items.find {|item| item.name == name}
  end
  
  def get_coupon(name)
    @coupons.find {|coupon| coupon.name == name}
  end
    
  def register(product, price, promo={})
    if get_item(product)
      raise "Already exists"
    else
      @items.push(Item.new(product, price, new_promo(promo)))
    end  
  end
  
  def register_coupon(name, discount_type)
    if self.get_coupon(name) #equal
      raise "This item is already registered"
    else
      @coupons.push(Coupon.new_coupon(name,discount_type))
    end  
  end
  
  def new_cart()
    Cart.new(self)
  end
  
  def new_promo(type)
    case type.keys[0]
      when nil then NullPromo.new()
      when :get_one_free then GetOneFreePromo.new(type.values[0])
      when :package
        PackagePromo.new(type.values[0].keys[0], type.values[0].values[0])
      when :threshold
        TresholdPromo.new(type.values[0].keys[0], type.values[0].values[0])
    end 
  end
  
end

class Cart
  attr_accessor :items
  attr_reader :inventory, :coupon
  
  def initialize(inv)
    @items = Array.new
    @inventory = inv
  end
  
  def put_item(name, quantity)
    inv_item = @inventory.get_item(name)
    if(inv_item)
      @items << ItemInCart.new(inv_item,quantity)
    else
      raise "There is no such item in inventory."
    end  
  end
  
  def add(product, quantity=1)
    cart_item = @items.find {|item| item.name == product}
    if (cart_item)
      cart_item.count += quantity
    else
      put_item(product,quantity)
    end
  end
  
  def use(coupon)
    if not (@coupon = @inventory.get_coupon(coupon))
      raise "There is no such coupon in inventory."
    end
  end
  
  def gross()
    items.inject(0) {|s, it| s + it.get_total - it.get_discount}
  end
  
  def total()
    if @coupon
      self.gross - @coupon.apply(self)
    else
      self.gross
    end
  end
  
  def invoice()
    line = "+"+"-"*48+"+"+"-"*10+"+"+"\n"
    invoice_input = line+"| %-42s %s |%9s |\n" % ["Name","qty", "price"]+line
    @items.each { |item| invoice_input += item.item_s }
    c=@coupon ?
    "| %-46s |%9.2f |\n" %["#{@coupon.coupon_s}","-#{@coupon.apply(self)}"]:"" 
    t = "| %-46s |%9.2f |\n" %["TOTAL","#{self.total}"]
    invoice_input + c + line+t+line
  end  
  
  
  def inv_row(it)
    if it.promotion
      i= "| %-42s %d |%9.2f |\n" %["#{it.name}","#{it.count}","#{it.get_total}"]
      i+="|%3%-43s |%9.2f |\n"%["#{it.promotion.promo_s}","-#{it.get_discount}"]
    else 
      "| %-44s %d |%9.2f |\n" %["#{it.name}","#{it.count}", "#{it.get_total}"]
    end
  end
end

class Item
  attr_accessor :name, :price, :promotion
  def initialize(name, price, promotion)
    if (name.length <= 40 && price.to_d.between?( 0.01, 999.99))
      @name, @price = name, price
      @promotion = promotion
    else 
      raise "Invalid parameters passed."
    end
  end
  def price_d()
    @price.to_d
  end
end

class ItemInCart < Item
  attr_accessor :count
  def initialize(item,count)
    if count.between?(0,99) 
       super( item.name, item.price, item.promotion)
       @count = count
    else raise "Too much items!"
    end
  end
  
  def get_total()
    price_d*@count
  end
  
  def get_discount()
    @promotion.calculate(self)
  end
  
  def item_s()
    pr = ""
    if(@promotion.promo_s != "")
      pr="|   %-44s | %8.2f |\n" %["#{@promotion.promo_s}", "-#{get_discount}"]
    end
    "| %-40s %5d | %8.2f |\n" %["#{@name}","#{@count}", "#{get_total}"] + pr
  end
end

class NullPromo 
  def calculate(item)
    0
  end
  def promo_s()
    ""
  end
end

class GetOneFreePromo 
  attr_accessor :count
  
  def initialize(count)
    @count = count
  end  
  def calculate(item)
    item.price_d*(item.count/@count)
  end
  def promo_s()
    "(buy #{count-1}, get 1 free)"
  end
end

class PackagePromo 
  attr_accessor :percent, :count
  def initialize(count, percent)
    @count= count
    @percent = percent
  end
  
  def calculate(item)
    if item.count >= @count
      (item.count/@count)*@count*item.price_d*@percent/100 
    else
      0
    end
  end
  def promo_s()
    "(get %d%% off for every %s)" % [@percent, @count]
  end
end

class TresholdPromo 
  attr_accessor :percent, :count
  def initialize(count, percent)
    @count= count
    @percent = percent
  end
  def calculate(item)
    if item.count >= @count 
      (item.count - @count.to_f.to_d)*item.price_d*@percent/100 
    else 
      0 
    end
  end
  def promo_s()
    suffix = {1 => 'st', 2 => 'nd', 3 => 'rd'}.fetch @count, 'th'
    "(%d%% off of every after the %d%s)" % [@percent, @count, suffix]
  end
end

class Coupon
  attr_accessor :name
  def initialize(name)
    @name = name
  end 
  def Coupon.new_coupon(name, type)
    case type.keys[0]
      when :percent
        PercentageCoupon.new(name,type.values[0])
      when :amount
        AmountCoupon.new(name, type.values[0])
    end
  end
end

class PercentageCoupon < Coupon
  attr_accessor :percent
  def initialize(name,percent)
    super(name)
    @percent = percent
  end
  def apply(cart)
    cart.gross*@percent/100
  end
  def coupon_s()
    "Coupon #{@name} - #{@percent}% off"
  end
end

class AmountCoupon < Coupon
  attr_accessor :amount
  def initialize(name,amount)
    super(name)
    @amount = amount
  end
  def apply(cart)
    [cart.gross, @amount.to_d].min
  end
  def coupon_s()
    "Coupon #{@name} - #{@amount} off"
  end
end
