module SolicitationHelper
  ## Google Ads helpers
  # Our ads params are
  # mtm_campaign=googleads-{campaignid}
  # mtm_kwd={creative}-{keyword}
  def link_to_tracked_campaign(solicitation)
    campaign_components = solicitation.campaign&.split('-', 2)
    if campaign_components.present? && campaign_components.first == 'googleads'
      link_to solicitation.campaign, "https://ads.google.com/aw/adgroups?campaignId=#{campaign_components.last}"
    else
      solicitation.campaign
    end
  end

  def link_to_tracked_ad(solicitation)
    campaign_components = solicitation.campaign&.split('-', 2)
    if campaign_components.present? && campaign_components.first == 'googleads'
      keyword_components = solicitation.provenance_detail.split('-', 2)
      link_to solicitation.provenance_detail, "https://ads.google.com/aw/ads/versions?adId=#{keyword_components.first}"
    else
      solicitation.provenance_detail
    end
  end

  STATUS_ACTION_COLORS = {
    in_progress: %w[yellow],
    processed: %w[grey],
    canceled: %w[red]
  }

  def status_action_link(solicitation, new_status, classes = %w[])
    name = Solicitation.human_attribute_value(:status, new_status, context: :action)
    path = update_status_conseiller_solicitation_path(solicitation, status: new_status)
    classes += STATUS_ACTION_COLORS[new_status.to_sym]
    tag.li class: 'fr-menu__item' do
      link_to name, path, method: :post, remote: true, class: classes.join(' ')
    end
  end

  def subject_button(solicitation, classes = %[])
    if solicitation.diagnosis.present? && solicitation.diagnosis.needs.present?
      button_for_editable_subject(solicitation.diagnosis.needs.first, classes)
    else
      button_for_non_editable_subject(solicitation, classes)
    end
  end

  def link_to_diagnosis(diagnosis)
    text = if diagnosis.step_completed?
      t('helpers.solicitation.view_completed_analysis')
    else
      t('helpers.solicitation.analysis_in_progress', step: diagnosis.human_attribute_value(:step))
    end

    link_to text, [:conseiller, diagnosis], class: 'button'
  end

  def display_region(region, territory_params)
    # display region if there is no region filter
    return unless ((territory_params.present? && (territory_params == 'uncategorisable')) || territory_params.blank?) && region.present?
    tag.li(class: 'item') do
      t('helpers.solicitation.localisation_html', region: region.name)
    end
  end

  private

  def button_for_editable_subject(need, classes)
    title = t('helpers.solicitation.modify_subject', subject: need.subject)
    path = needs_conseiller_diagnosis_path(need.diagnosis)
    link_to need.subject.label, path, class: classes + ' fr-icon-settings-5-fill fr-btn--icon-right ', title: title
  end

  def button_for_non_editable_subject(solicitation, classes)
    tag.button(class: classes, disabled: 'disabled') { solicitation.landing_subject.title }
  end
end
