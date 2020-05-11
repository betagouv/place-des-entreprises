module SolicitationHelper
  def needs_description(solicitation)
    needs_keys = solicitation.needs.select{ |_,v| v == "1" }.keys.sort
    localized_needs = needs_keys.map{ |key| I18n.t("solicitations.needs.short.#{key}") }
    tag.ul do
      localized_needs.map{ |need| tag.li(need) }.join.html_safe
    end
  end

  ## Google Ads helpers
  # Our ads params are
  # pk_campaign=googleads-{campaignid}
  # pk_kwd={creative}-{keyword}
  def link_to_tracked_campaign(solicitation)
    campaign_components = solicitation.pk_campaign.split('-', 2)
    if campaign_components.first == 'googleads'
      link_to solicitation.pk_campaign, "https://ads.google.com/aw/adgroups?campaignId=#{campaign_components.last}"
    else
      solicitation.pk_campaign
    end
  end

  def link_to_tracked_ad(solicitation)
    campaign_components = solicitation.pk_campaign.split('-', 2)
    if campaign_components.first == 'googleads'
      keyword_components = solicitation.pk_kwd.split('-', 2)
      link_to solicitation.pk_kwd, "https://ads.google.com/aw/ads/versions?adId=#{keyword_components.first}"
    else
      solicitation.pk_kwd
    end
  end

  STATUS_ACTION_COLORS = {
    in_progress: %w[yellow],
    processed: %w[grey],
    canceled: %w[red]
  }

  def status_action_link(solicitation, new_status, classes = %w[])
    name = Solicitation.human_attribute_name("statuses_actions.#{new_status}")
    path = update_status_solicitation_path(solicitation, status: new_status)
    classes += STATUS_ACTION_COLORS[new_status.to_sym]
    link_to name, path, method: :post, remote: true, class: classes.join(' ')
  end

  def selected_options_tags(solicitation, classes = %[])
    tags = solicitation.landing_options_slugs.map do |slug|
      option = LandingOption.find_by(slug: slug)
      if option.present?
        title_components = {}
        if option.preselected_institution_slug.present?
          institution = option.preselected_institution&.name || option.preselected_institution_slug
          title_components[t('attributes.institution')] = institution
        end
        if option.preselected_subject_slug.present?
          subject = option.preselected_subject&.label || option.preselected_subject_slug
          title_components[t('attributes.subject')] = subject
        end

        title = title_components.map{ |k,v| "#{k} : #{v}" }.join("\n")

        content_tag(:div, option.slug, class: classes, title: title)
      else
        content_tag(:div, slug, class: classes)
      end
    end

    tags.join.html_safe
  end
end
