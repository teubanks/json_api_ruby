Phone = Struct.new(:id, :manufacturer, :model, :number)
Car = Struct.new(:id, :make, :model, :year, :color)

Person = Struct.new(:name, :occupation, :address) do
  def id
    '91f37652-c015-4e04-ba55-815fb5407d12'
  end

  def to_s
    'people'
  end

  def cars
    [
      Car.new('4c4ceb1b-ce04-41ed-bb15-88c507cebcb8', 'tesla', 'model s', 2016, 'red'),
      Car.new('a44db3aa-2aa3-4602-89b5-ba67b44cb062', 'tesla', 'model s', 2016, 'black')
    ]
  end

  def phone
    Phone.new('8ce1c5f8-4081-4de2-b126-5dbf31f8aa1e', 'Apple', 'iPhone 6s Plus', '512-867-5309')
  end
end
