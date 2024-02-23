# frozen_string_literal: true

ActiveAdmin.register Match do
  include CsvExportable

  menu parent: :needs, priority: 2

  ## Index
  #
  includes :need, :facility, :company, :related_matches,
           :advisor, :advisor_antenne, :advisor_institution,
           :expert, :expert_antenne, :expert_institution,
           :solicitation, :diagnosis,
           :landing, :landing_theme, :landing_subject,
           :subject, :theme,
           facility: :commune,
           need: :subject

  scope :sent, default: true, group: :all
  scope :all, group: :all
  scope :with_deleted_expert
  scope :to_support

  index do
    selectable_column
    column :match, sortable: :status do |m|
      div admin_link_to(m)
      human_attribute_status_tag m, :status
      status_tag t('attributes.is_archived'), class: :ok if m.is_archived
      div admin_attr(m, :sent_at) if m.sent_at.present?
    end
    column :solicitation_created_at do |m|
      if m.solicitation.present?
        div I18n.l(m.solicitation.created_at, format: :admin)
      end
    end
    column :need, sortable: :created_at do |m|
      div admin_link_to(m, :need)
      div admin_attr(m.facility, :commune)
      div I18n.l(m.created_at, format: :admin)
      human_attribute_status_tag m.need, :status
    end
    column :advisor do |m|
      div admin_link_to(m, :advisor)
      div admin_link_to(m, :advisor_antenne)
    end
    column :contacted_expert do |m|
      div admin_link_to(m, :expert)
      div admin_link_to(m, :expert_antenne)
      div link_to(I18n.t('active_admin.matches.need_page'), need_path(m.need))
    end
    column(:subject) do |m|
      div admin_link_to(m, :theme)
      div admin_link_to(m, :subject)
    end

    actions dropdown: true do |match|
      if match.is_archived
        item t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, match])
      else
        item t('archivable.archive'), polymorphic_path([:archive, :admin, match])
      end
    end
  end

  before_action :only => :index do
    @antennes_collection = if params[:q].present? && params[:q][:advisor_institution_id_eq].present?
      Antenne.where(institution_id: params[:q][:advisor_institution_id_eq])
    else
      Antenne.all
    end
  end

  ## Filtres entreprise
  filter :facility_siret_cont
  filter :solicitation_full_name_cont
  filter :solicitation_email_cont
  filter :solicitation_phone_number_cont
  filter :facility, as: :ajax_select, data: { url: :admin_facilities_path, search_fields: [:name] }
  filter :facility_naf_code, as: :string
  filter :company_legal_form_code, as: :string

  ## Filtres Mise en relation
  collection = -> { Match.human_attribute_values(:status, raw_values: true, context: :short).invert.to_a }
  filter :status, as: :select, collection: collection, label: I18n.t('attributes.status')
  filter :archived_in, as: :boolean, label: I18n.t('attributes.is_archived')
  filter :solicitation_created_at, as: :date_range
  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :expert_antenne, as: :ajax_select, collection: -> { @antennes_collection.pluck(:name, :id) },
         data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :expert_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :theme, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :subject, as: :ajax_select, collection: -> { Subject.not_archived.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }
  filter :facility_regions, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }, collection: -> { Territory.regions.pluck(:name, :id) }

  ## Filtres acquisition
  filter :landing, as: :select, collection: -> { Landing.not_archived.order(:slug).pluck(:slug, :id) }
  filter :solicitation_mtm_campaign, as: :string
  filter :solicitation_mtm_kwd, as: :string
  filter :landing_theme, as: :select, collection: -> { @landing_themes.order(:title).pluck(:title, :id) }
  filter :landing_subject, as: :select, collection: -> { @landing_subjects.order(:title).pluck(:title, :id) }

  before_action only: :index do
    @landing_themes = if params[:q].present? && params[:q][:landing_id_eq].present?
      Landing.find(params[:q][:landing_id_eq]).landing_themes.not_archived
    else
      LandingTheme.not_archived
    end
    @landing_subjects = if params[:q].present? && params[:q][:landing_subject_landing_theme_id_eq].present?
      LandingTheme.find(params[:q][:landing_subject_landing_theme_id_eq]).landing_subjects.not_archived
    else
      LandingSubject.not_archived
    end
  end

  ## Show
  #
  show do
    attributes_table do
      row(:status) { |m| human_attribute_status_tag m, :status }
      row(:need) do |m|
        human_attribute_status_tag m.need, :status
        div admin_link_to(m, :need)
        div do
          if m.diagnosis.step_completed?
            link_to(I18n.t('active_admin.matches.need_page'), need_path(m.need))
          else
            link_to(I18n.t('active_admin.matches.diagnosis_page'), conseiller_diagnosis_path(m.diagnosis))
          end
        end
      end
      row :created_at
      row :updated_at
      row :archived_at
      row :taken_care_of_at
      row :closed_at
      row :advisor do |m|
        if m.advisor.present?
          div admin_link_to(m, :advisor)
          div admin_link_to(m, :advisor_antenne)
        end
      end
      row :contacted_expert do |m|
        div admin_link_to(m, :expert)
        div admin_link_to(m, :expert_antenne)
      end
      row :subject
    end
  end

  ## Form
  #
  permit_params :expert_id, :subject_id, :status
  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: Match.human_attribute_values(:status).invert
      f.input :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
      themes = Theme.all
      collection = option_groups_from_collection_for_select(themes, :subjects, :label, :id, :label, resource.subject_id)
      f.input :subject, input_html: { :size => 20 }, collection: collection
    end

    f.actions
  end

  ## Actions
  #
  member_action :archive do
    resource.archive!
    redirect_back fallback_location: collection_path, notice: t('archivable.archive_done')
  end

  member_action :unarchive do
    resource.unarchive!
    redirect_back fallback_location: collection_path, notice: t('archivable.unarchive_done')
  end

  batch_action(I18n.t('archivable.archive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.archive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('archivable.archive_done')
  end

  batch_action(I18n.t('archivable.unarchive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.unarchive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('archivable.unarchive_done')
  end
end
