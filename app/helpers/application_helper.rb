module ApplicationHelper
  def som(amount)
    return "—" if amount.blank?
    "#{number_with_delimiter(amount, delimiter: ' ')} so'm"
  end

  def droplets(rating, count: nil)
    rating ||= 0
    full = rating.round
    html = (1..5).map { |i|
      %(<span class="drop #{'drop--on' if i <= full}" aria-hidden="true">#{droplet_svg}</span>)
    }.join
    label = rating.positive? ? rating.to_s : "Yangi"
    suffix = count ? %( <span class="drop-count">(#{count})</span>) : ""
    %(<span class="drops" title="#{label}">#{html} <span class="drop-num">#{label}</span>#{suffix}</span>).html_safe
  end

  def droplet_svg
    '<svg viewBox="0 0 24 24" width="14" height="14"><path d="M12 2C12 2 5 10.5 5 15a7 7 0 0 0 14 0c0-4.5-7-13-7-13z" fill="currentColor"/></svg>'
  end

  def uz_date(date)
    months = %w[yanvar fevral mart aprel may iyun iyul avgust sentabr oktabr noyabr dekabr]
    "#{date.day}-#{months[date.month - 1]}"
  end

  def status_badge(booking)
    %(<span class="badge badge--#{booking.status}">#{booking.status_label}</span>).html_safe
  end
end
