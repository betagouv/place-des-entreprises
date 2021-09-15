ActiveAdmin.register Logo do
  menu parent: :experts, priority: 3
  config.sort_order = "slug_asc"

  ## Index
  #
  index do
    selectable_column
    column :name
    column :slug
    column :image, class: 'logo' do |l|
      display_image(name: l.slug, path: "institutions/")
    end
    actions dropdown: true
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :slug
    end
  end

  ## Form
  #
  permit_params :slug, :name
end