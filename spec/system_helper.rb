def check_links_text(context)
  within(context) do
    all_links = all("a").map(&:text) # get text for all links
    all_links.each do |i|
      puts i
    end
  end
end

def create_base_dummy_data
  create(:antenne)
  create(:badge)
  create(:commune)
  create(:company)
  create(:contact)
  create(:diagnosis)
  create(:expert_subject)
  create(:expert)
  create(:facility)
  create(:feedback, :for_need)
  create(:institution_subject)
  create(:institution, show_on_list: true)
  create(:landing)
  create(:landing_theme)
  create(:landing_subject)
  create(:match)
  create(:subject)
  create(:theme)
  create(:user)
  create(:solicitation)
end

def side_menu_link(path)
  within('#fr-sidemenu-wrapper') do
    find("a[href='#{path}']").sibling('span')
  end
end

def create_home_landing
  create(:landing, :with_subjects, slug: 'accueil', title: 'Accueil')
end
