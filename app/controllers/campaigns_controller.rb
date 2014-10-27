class CampaignsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_campaign, except: [:index]

  def index
    @campaigns = CertificationCampaign.where(user_id: current_user)
  end

  def show
    @generators = @campaign.certificate_generators.includes(:dataset, :certificate)
    respond_to do |want|
      want.html
      want.csv do
        csv = CSV.generate do |csv|
          csv << [
            "Success?",
            "Published?",
            "Documentation URL",
            "Certificate URL",
            "User"
          ]
          @generators.each do |gen|
            csv << [
              "true",
              gen.certificate.published?,
              gen.dataset.documentation_url,
              dataset_certificate_url(gen.dataset, gen.certificate),
              gen.dataset.user_email
            ]
          end
        end
        send_data csv, filename: "#{@campaign.name}.csv", type: "text/csv; header=present; charset=utf-8"
      end
    end
  end

  private

  def get_campaign
    @campaign = CertificationCampaign.find(params[:id])
    raise ActionController::RoutingError.new('Forbidden') unless @campaign.user_id == current_user.id
  end

end
