# frozen_string_literal: true

ActiveAdmin.register CompanySatisfaction do
  menu parent: :companies, priority: 3

  controller do
    include DynamicallyFiltrable
  end

  ## Index
  #
  before_action only: :index do
    init_subjects_filter
  end

  includes :need, :landing, :solicitation, :subject, :facility, :shared_satisfactions, :shared_satisfaction_experts, :shared_satisfaction_users, :diagnosis, :facility
  config.sort_order = 'created_at_desc'

  scope :all, default: true

  index do
    selectable_column
    column :contacted_by_expert
    column :useful_exchange
    column :comment do |s|
      div s.comment
      if s.shared
        br
        div t('active_admin.company_satisfaction.shared_with')
        s.shared_satisfaction_experts.each do |e|
          admin_link_to e
        end
      end
    end
    column :need do |s|
      link_to s.need.to_s, conseiller_diagnosis_path(s.need.diagnosis)
    end
    column :landing do |s|
      admin_link_to(s.landing) || '-'
    end
    column "#{t('activerecord.attributes.solicitation.tracking')}" do |s|
      if s.solicitation&.campaign.present?
        div "#{t('activerecord.attributes.solicitation.mtm_campaign')} : #{link_to_tracked_campaign(s.solicitation)}".html_safe
      end
      if s.solicitation&.provenance_detail.present?
        div "#{t('activerecord.attributes.solicitation.mtm_kwd')} : « #{link_to_tracked_ad(s.solicitation)} »".html_safe
      end
    end

    column :created_at

    actions dropdown: true do |cs|
      item t('active_admin.company_satisfaction.share'), share_admin_company_satisfaction_path(cs)
    end
  end

  filter :created_at
  filter :contacted_by_expert
  filter :useful_exchange
  filter :with_comment, as: :select, collection: [["Avec commentaire", 'with_comment'], ["Sans commentaire", 'without_comment']]
  filter :theme, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :subject, as: :ajax_select, collection: -> { @subjects.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }
  filter :done_institutions, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :facility, as: :ajax_select, data: { url: :admin_facilities_path, search_fields: [:name] }
  filter :solicitation_email_cont
  filter :facility_regions, collection: -> { Territory.regions.order(:name) }
  filter :landing, as: :ajax_select, collection: -> { Landing.not_archived.pluck(:title, :id) }, data: { url: :admin_landings_path, search_fields: [:title] }
  filter :shared, as: :select, collection: [["Oui", 'shared'], ["Non", 'not_shared']]

  filter :solicitation_mtm_campaign, as: :string
  filter :solicitation_mtm_kwd, as: :string

  ## CSV
  #
  csv do
    column :id
    column :created_at
    column :contacted_by_expert
    column :useful_exchange
    column :comment
    column(:landing) { |s| s.landing&.slug }
    column(:subject) { |s| s.subject&.slug }
    column(t('activerecord.attributes.solicitation.mtm_campaign')) do |s|
      s.solicitation&.campaign.presence
    end
    column(t('activerecord.attributes.solicitation.mtm_kwd')) do |s|
      s.solicitation&.provenance_detail
    end
  end

  ## Show
  #
  show do
      attributes_table do
          row :created_at
          row :contacted_by_expert
          row :useful_exchange
          row :comment
          row :need
          row(:shared_with) do |s|
            div raw shared_satisfactions_links(s.shared_satisfactions) if s.shared_satisfactions.any?
          end
        end
    end

  ## Actions
  #

  action_item :share, only: :show do
    link_to t('active_admin.company_satisfaction.share'), { action: :share }, data: { confirm: t('active_admin.company_satisfaction.share_confirmation') }
  end

  member_action :share do
    CreateSharedSatisfactionJob.perform_later(resource.id)
    redirect_back fallback_location: collection_path, notice: t('active_admin.company_satisfaction.shared')
  end

  batch_action I18n.t('active_admin.company_satisfaction.share'), { action: :share, confirm: I18n.t('active_admin.company_satisfaction.share_confirmation') } do |ids|
    CompanySatisfaction.where(id: ids).find_each { |satisfaction| CreateSharedSatisfactionJob.perform_later(satisfaction.id) }
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.company_satisfaction.shared')
  end
end
