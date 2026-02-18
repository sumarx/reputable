module ApplicationHelper
  include Pagy::Loader

  def nav_link_classes(active = false)
    base_classes = "flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-200"
    if active
      "#{base_classes} bg-indigo-600 text-white"
    else
      "#{base_classes} text-gray-300 hover:bg-gray-700 hover:text-white"
    end
  end

  # Generate visual star rating display
  def star_rating(rating, max_stars = 5)
    return "" if rating.nil?
    
    rating = rating.to_f
    full_stars = rating.floor
    half_star = (rating - full_stars) >= 0.5
    empty_stars = max_stars - full_stars - (half_star ? 1 : 0)
    
    content_tag :div, class: "flex items-center gap-0.5" do
      html = ""
      
      # Full stars
      full_stars.times do
        html += content_tag(:svg, class: "w-4 h-4 text-yellow-400 fill-current", viewBox: "0 0 24 24") do
          content_tag(:path, "", d: "M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z")
        end
      end
      
      # Half star
      if half_star
        html += content_tag(:svg, class: "w-4 h-4 text-yellow-400", viewBox: "0 0 24 24") do
          content_tag(:defs) do
            content_tag(:linearGradient, id: "half-star") do
              content_tag(:stop, "", offset: "50%", "stop-color": "#fbbf24") +
              content_tag(:stop, "", offset: "50%", "stop-color": "#e5e7eb")
            end
          end +
          content_tag(:path, "", d: "M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z", fill: "url(#half-star)")
        end
      end
      
      # Empty stars
      empty_stars.times do
        html += content_tag(:svg, class: "w-4 h-4 text-gray-300", viewBox: "0 0 24 24", fill: "currentColor") do
          content_tag(:path, "", d: "M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z")
        end
      end
      
      html.html_safe
    end
  end

  # Check if current page matches for nav highlighting
  def current_page_match?(path_or_paths)
    paths = Array(path_or_paths)
    paths.any? { |path| current_page?(path) || request.fullpath.start_with?(path) }
  end
end
