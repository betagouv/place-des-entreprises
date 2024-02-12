ActiveAdmin.register EmailRetention do
  menu parent: :companies

  ## Index
  #
  index do
    selectable_column
    id_column
    column :waiting_time
    column :subject
    column :first_subject
    column :second_subject
  end

  ## Show
  #
  show do
    attributes_table do
      row :waiting_time
      row :subject
      row :email_subject
      row(:first_paragraph) { |er| er.first_paragraph.html_safe }
      row :first_subject
      row :first_subject_label
      row :second_subject
      row :second_subject_label
    end
    panel 'email' do
      div I18n.t('mailers.hello')
      div email_retention.first_paragraph.html_safe
      div I18n.t('mailers.company_mailer.intelligent_retention.and_you').html_safe
      div link_to email_retention.first_subject_label, new_solicitation_url(Landing.accueil, Landing.accueil.landing_subjects.joins(:subject).find_by(subject: email_retention.first_subject))
      div link_to email_retention.second_subject_label, new_solicitation_url(Landing.accueil, Landing.accueil.landing_subjects.joins(:subject).find_by(subject: email_retention.second_subject))
      div I18n.t('mailers.company_mailer.why_this_message_html').html_safe
      div I18n.t('mailers.company_mailer.explanation_html').html_safe
    end
  end

  ## Form
  #
  permit_params :subject_id, :first_subject_id, :first_subject_label, :second_subject_id, :second_subject_label, :email_subject,
                :first_paragraph, :waiting_time

  themes = Theme.all.ordered_for_interview

  form do |f|
    f.inputs do
      f.input :waiting_time
      f.input :email_subject, as: :string
      f.input :subject_id, as: :select, collection: option_groups_from_collection_for_select(themes, :subjects_ordered_for_interview, :label, :id, :label, f.object&.subject&.id)
      f.input :first_paragraph, as: :quill_editor
      f.input :first_subject_id, as: :select, collection: option_groups_from_collection_for_select(themes, :subjects_ordered_for_interview, :label, :id, :label, f.object&.first_subject&.id)
      f.input :first_subject_label
      f.input :second_subject_id, as: :select, collection: option_groups_from_collection_for_select(themes, :subjects_ordered_for_interview, :label, :id, :label, f.object&.second_subject&.id)
      f.input :second_subject_label
    end

    f.actions
  end
end
