module ApplicationHelper
  def som(amount)
    return "—" if amount.blank?
    "#{number_with_delimiter(amount, delimiter: ' ')} #{t('common.currency')}"
  end

  def service_price(service)
    service.per_minute? ? "#{som(service.price)}/#{t('common.per_minute')}" : som(service.price)
  end

  def wash_price_from(wash)
    cheapest = wash.services.min_by(&:price)
    return nil unless cheapest
    t("common.price_from", price: service_price(cheapest))
  end

  def droplets(rating, count: nil)
    rating ||= 0
    full = rating.round
    html = (1..5).map { |i|
      %(<span class="drop #{'drop--on' if i <= full}" aria-hidden="true">#{droplet_svg}</span>)
    }.join
    label = rating.positive? ? rating.to_s : I18n.t("bookings.status.yangi")
    suffix = count ? %( <span class="drop-count">(#{count})</span>) : ""
    %(<span class="drops" title="#{label}">#{html} <span class="drop-num">#{label}</span>#{suffix}</span>).html_safe
  end

  def droplet_svg
    '<svg viewBox="0 0 24 24" width="14" height="14"><path d="M12 2C12 2 5 10.5 5 15a7 7 0 0 0 14 0c0-4.5-7-13-7-13z" fill="currentColor"/></svg>'
  end

  def uz_date(date)
    I18n.l(date, format: :day_month)
  end

  def status_badge(booking)
    %(<span class="badge badge--#{booking.status}">#{booking.status_label}</span>).html_safe
  end

  # data: {label => qiymat} tartiblangan hash. Chartkick/JS kutubxonasiz,
  # oddiy CSS ustunlar bilan chiziladi (loyihaning "og'ir bog'liqliksiz" uslubiga mos).
  def bar_chart(data, unit: nil)
    max = data.values.max.to_f
    bars = data.map { |label, value|
      pct = max.positive? ? (value / max * 100).round(1) : 0
      value_label = unit ? "#{number_with_delimiter(value)} #{unit}" : number_with_delimiter(value)
      %(<div class="bar-col">
          <div class="bar-col__track"><div class="bar-col__fill" style="height:#{pct}%" title="#{value_label}"></div></div>
          <span class="bar-col__label">#{label}</span>
        </div>)
    }.join
    %(<div class="bars">#{bars}</div>).html_safe
  end
end
