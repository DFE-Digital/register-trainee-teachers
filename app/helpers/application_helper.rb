module ApplicationHelper
  def boilerplate(array)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: nil))
    result
  end
end
