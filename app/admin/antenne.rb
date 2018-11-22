ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 1
  includes :institution, :communes, :territories, :experts, :advisors

  permit_params [
    :name,
    :institution_id,
    :insee_codes,
    advisor_ids: [],
    expert_ids: [],
  ]

  ## Index
  #

  config.sort_order = 'name_asc'

  index do
    selectable_column
    id_column
    column :name
    column :institution
    column :experts, :experts_count
    column(:advisors) { |a| a.advisors.size }
    column(:communes) { |a| intervention_zone_short_description(a) }
    # The two following lines are actually “N+1 requests” expensive
    # We’ll probably want to remove them or use some counter at some point.
    column(I18n.t('attributes.match_sent.other')) { |a| "#{a.sent_matches.size}" }
    column(I18n.t('attributes.match_received.other')) { |a| "#{a.received_matches.size}" }
  end

  filter :name
  filter :institution_name, as: :string, label: I18n.t('activerecord.models.institution.one')

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :institution
      row(:communes) { |a| intervention_zone_description(a) }
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.antenne.advisors'),
      users: antenne.advisors
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.antenne.experts'),
      experts: antenne.experts
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_sent', count: antenne.sent_matches.size),
      matches: antenne.sent_matches
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_received', count: antenne.received_matches.size),
      matches: antenne.received_matches
    }
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name],
        limit: 999,
      }

      f.input :insee_codes
    end

    f.inputs do
      f.input :advisors, label: t('activerecord.attributes.antenne.advisors'), as: :ajax_select, data: {
        url: :admin_users_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.inputs do
      f.input :experts, label: t('activerecord.attributes.antenne.experts'), as: :ajax_select, data: {
        url: :admin_experts_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.actions
  end
end
