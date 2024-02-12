# frozen_string_literal: true

require 'rails_helper'

describe 'about', :js, type: :feature do
  subject { page }

  before do
    create_home_landing
    create_list :match, 2, status: :quo
    create_list :match, 2, status: :taking_care
    create_list :match, 2, status: :done
    create_list :match, 2, status: :done_no_help
    create_list :match, 2, status: :done_not_reachable
    create_list :match, 2, status: :not_for_me
  end

  describe '/stats' do
    before { visit '/stats' }

    it { is_expected.to be_accessible }
  end
end
