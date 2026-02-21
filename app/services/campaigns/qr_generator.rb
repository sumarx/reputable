class Campaigns::QrGenerator
  def initialize(campaign)
    @campaign = campaign
  end

  def call
    return nil unless @campaign.slug.present?

    begin
      generate_qr_code
    rescue => error
      Rails.logger.error "QR code generation failed for campaign #{@campaign.id}: #{error.message}"
      nil
    end
  end

  private

  def generate_qr_code
    qr = RQRCode::QRCode.new(campaign_url, size: 6, level: :h)
    
    # Generate SVG
    svg = qr.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
    
    svg
  end

  def campaign_url
    host = ENV.fetch('APP_HOST', 'localhost:3000')
    protocol = host.start_with?('localhost') ? 'http' : 'https'

    "#{protocol}://#{host}/c/#{@campaign.slug}"
  end
end