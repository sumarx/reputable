module ApplicationHelper
  def nav_link_classes(active = false)
    base_classes = "flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-200"
    if active
      "#{base_classes} bg-indigo-600 text-white"
    else
      "#{base_classes} text-gray-300 hover:bg-gray-700 hover:text-white"
    end
  end
end
