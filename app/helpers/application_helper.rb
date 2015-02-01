module ApplicationHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def present_each objs, klass = nil, &blk
    objs.each do |obj|
      present(obj, klass, &blk)
    end
  end
end
