# frozen_string_literal: true

require 'rails_helper'

describe SolicitationHelper do
  describe 'display_region' do
    context 'without region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, nil) }

      it 'return region' do
        is_expected.to eq "<li class=\"item\">#{CGI.unescapeHTML(I18n.t('helpers.solicitation.localisation_html', region: region.name))}</li>"
      end
    end

    context 'with region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, 'Region Bretagne') }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end

    context 'without region for solicitation' do
      let(:region) { nil }

      subject { helper.display_region(region, nil) }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end
  end
end
